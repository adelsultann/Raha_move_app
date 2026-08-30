import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

/// Enforces RAHA-026 cache policy without depending on a network or file plugin.
final class MediaPreparationService {
  MediaPreparationService({
    required this.resolver,
    required this.downloader,
    required this.files,
    required this.cache,
    required this.network,
    required this.accessScope,
    required this.clock,
    this.maximumCacheBytes = 500 * 1024 * 1024,
  });

  static const int defaultMaximumCacheBytes = 500 * 1024 * 1024;

  final TrustedMediaResolver resolver;
  final MediaDownloadClient downloader;
  final MediaFileStore files;
  final MediaCacheIndex cache;
  final MediaNetworkStatus network;
  final MediaAccessScope accessScope;
  final DateTime Function() clock;
  final int maximumCacheBytes;

  /// Prepares every active item. Explicit user start is the sole path allowed
  /// to download missing active media on cellular data.
  Future<RoutineMediaPreparation> prepareActiveRoutine(
    List<MediaDelivery> activeMedia, {
    required bool explicitUserStart,
    Iterable<String> nextToPreloadMediaIds = const [],
  }) async {
    final pins = {
      ...activeMedia.map((media) => media.mediaId),
      ...nextToPreloadMediaIds,
    };
    final results = <String, MediaPreparationResult>{};
    for (final media in activeMedia) {
      results[media.mediaId] = await _prepare(
        media,
        pinnedMediaIds: pins,
        explicitUserStart: explicitUserStart,
      );
    }
    return RoutineMediaPreparation(results);
  }

  /// Automatic preloading is Wi-Fi only. A verified cache is always usable.
  Future<MediaPreparationResult> preloadNext(
    MediaDelivery media, {
    required Iterable<String> activeRoutineMediaIds,
  }) => _prepare(
    media,
    pinnedMediaIds: {...activeRoutineMediaIds, media.mediaId},
    explicitUserStart: false,
  );

  /// Retries through the same policy and never exposes authorization details.
  Future<MediaPreparationResult> retry(
    MediaDelivery media, {
    required Iterable<String> pinnedMediaIds,
    required bool explicitUserStart,
  }) => _prepare(
    media,
    pinnedMediaIds: pinnedMediaIds.toSet(),
    explicitUserStart: explicitUserStart,
  );

  Future<MediaPreparationResult> _prepare(
    MediaDelivery media, {
    required Set<String> pinnedMediaIds,
    required bool explicitUserStart,
  }) async {
    await _purgeRevokedEntitlements();
    final now = clock().toUtc();
    if (!accessScope.canAccess(media, now)) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.entitlementRequired,
        canRetry: false,
      );
    }
    final cached = await _verifiedCache(media);
    if (cached != null) return cached;
    // Keep stale bytes until the replacement is committed so a failed attempt
    // or storage-needed outcome cannot destroy an otherwise verified file.
    final staleCache = await cache.find(
      ownerId: accessScope.ownerId,
      mediaId: media.mediaId,
    );

    final currentNetwork = await network.currentNetwork();
    if (currentNetwork == MediaNetwork.offline) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.offline,
      );
    }
    if (!explicitUserStart && currentNetwork != MediaNetwork.wifi) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.networkRestricted,
        canRetry: false,
      );
    }

    EphemeralMediaUrl authorization;
    try {
      authorization = await resolver.resolve(
        MediaAuthorizationRequest(
          deliveryReference: media.deliveryReference,
          accessScope: accessScope,
        ),
      );
    } catch (_) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.authorizationUnavailable,
      );
    }
    Uint8List bytes;
    try {
      bytes = await downloader.download(authorization);
    } catch (_) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.downloadFailed,
      );
    }
    if (_sha256(bytes) != media.checksumSha256.toLowerCase()) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.integrityMismatch,
      );
    }
    if (!await _makeRoom(bytes.length, pinnedMediaIds)) {
      return MediaStorageNeeded(
        mediaId: media.mediaId,
        requiredBytes: bytes.length,
      );
    }

    return _storeDownloaded(
      media,
      bytes,
      staleCache: staleCache,
      pinnedMediaIds: pinnedMediaIds,
    );
  }

  Future<MediaPreparationResult> _storeDownloaded(
    MediaDelivery media,
    Uint8List bytes, {
    required CachedMedia? staleCache,
    required Set<String> pinnedMediaIds,
  }) async {
    String? temporaryPath;
    try {
      temporaryPath = await files.writeTemporary(bytes);
      final path = files.pathFor(
        ownerId: accessScope.ownerId,
        mediaId: media.mediaId,
        checksumSha256: media.checksumSha256,
      );
      await files.commitTemporary(temporaryPath: temporaryPath, path: path);
      final now = clock().toUtc();
      await cache.put(
        CachedMedia(
          ownerId: accessScope.ownerId,
          mediaId: media.mediaId,
          path: path,
          version: media.version,
          checksumSha256: media.checksumSha256,
          requiredEntitlement: media.requiredEntitlement,
          byteSize: bytes.length,
          lastVerifiedAccess: now,
        ),
      );
      if (staleCache != null && staleCache.path != path) {
        await _deleteQuietly(staleCache.path);
      }
      return MediaPrepared(
        mediaId: media.mediaId,
        localPath: path,
        fromCache: false,
      );
    } on MediaStorageException {
      if (temporaryPath != null) await _deleteQuietly(temporaryPath);
      if (await _evictOneEligible(pinnedMediaIds)) {
        return _storeDownloaded(
          media,
          bytes,
          staleCache: staleCache,
          pinnedMediaIds: pinnedMediaIds,
        );
      }
      return MediaStorageNeeded(
        mediaId: media.mediaId,
        requiredBytes: bytes.length,
      );
    } catch (_) {
      if (temporaryPath != null) await _deleteQuietly(temporaryPath);
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.cacheWriteFailed,
      );
    }
  }

  Future<bool> _evictOneEligible(Set<String> pinnedMediaIds) async {
    final entries = await cache.allVerifiedByLeastRecentAccess();
    for (final entry in entries) {
      if (entry.ownerId == accessScope.ownerId &&
          pinnedMediaIds.contains(entry.mediaId)) {
        continue;
      }
      try {
        if (await files.exists(entry.path)) await files.delete(entry.path);
        await cache.remove(ownerId: entry.ownerId, mediaId: entry.mediaId);
        return true;
      } catch (_) {
        // Try the next eligible entry. Failed entries retain their index.
      }
    }
    return false;
  }

  Future<MediaPrepared?> _verifiedCache(MediaDelivery media) async {
    final cached = await cache.find(
      ownerId: accessScope.ownerId,
      mediaId: media.mediaId,
    );
    if (cached == null ||
        cached.ownerId != accessScope.ownerId ||
        cached.requiredEntitlement != media.requiredEntitlement ||
        cached.version != media.version ||
        cached.checksumSha256.toLowerCase() !=
            media.checksumSha256.toLowerCase()) {
      return null;
    }
    try {
      if (!await files.exists(cached.path)) return null;
      if (_sha256(await files.read(cached.path)) !=
          media.checksumSha256.toLowerCase()) {
        return null;
      }
      await cache.touch(
        ownerId: accessScope.ownerId,
        mediaId: media.mediaId,
        at: clock().toUtc(),
      );
      return MediaPrepared(
        mediaId: media.mediaId,
        localPath: cached.path,
        fromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _makeRoom(int requiredBytes, Set<String> pinnedMediaIds) async {
    final entries = await cache.allVerifiedByLeastRecentAccess();
    var usage = entries.fold<int>(0, (total, entry) => total + entry.byteSize);
    var available = await files.availableBytes();
    for (final entry in entries) {
      if (usage + requiredBytes <= maximumCacheBytes &&
          (available == null || available >= requiredBytes)) {
        break;
      }
      if (entry.ownerId == accessScope.ownerId &&
          pinnedMediaIds.contains(entry.mediaId)) {
        continue;
      }
      try {
        await files.delete(entry.path);
        await cache.remove(ownerId: entry.ownerId, mediaId: entry.mediaId);
        usage -= entry.byteSize;
        if (available != null) available += entry.byteSize;
      } catch (_) {
        // A failed eviction leaves its verified index entry intact and simply
        // makes this attempt less likely to fit.
      }
    }
    return usage + requiredBytes <= maximumCacheBytes &&
        (available == null || available >= requiredBytes);
  }

  /// Entitlement loss immediately makes matching private bytes inaccessible
  /// and removes them before any new playback/download attempt.
  Future<void> _purgeRevokedEntitlements() async {
    final now = clock().toUtc();
    final entries = await cache.allVerifiedByLeastRecentAccess();
    for (final entry in entries) {
      if (entry.ownerId != accessScope.ownerId) continue;
      final entitlement = entry.requiredEntitlement;
      if (entitlement == null ||
          accessScope.hasActiveEntitlement(entitlement, now)) {
        continue;
      }
      if (await _deleteIfPresent(entry.path)) {
        await cache.remove(ownerId: entry.ownerId, mediaId: entry.mediaId);
      }
    }
  }

  Future<bool> _deleteIfPresent(String path) async {
    try {
      if (await files.exists(path)) await files.delete(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await files.delete(path);
    } catch (_) {}
  }

  static String _sha256(Uint8List bytes) => sha256.convert(bytes).toString();
}
