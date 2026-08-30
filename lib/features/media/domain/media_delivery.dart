import 'dart:typed_data';

/// A provider-neutral media record supplied by the published catalog.
///
/// [deliveryReference] is an opaque server-issued reference, never a storage
/// key, provider identifier, or URL. [version] changes whenever the published
/// delivery bytes change.
final class MediaDelivery {
  const MediaDelivery({
    required this.mediaId,
    required this.deliveryReference,
    required this.version,
    required this.checksumSha256,
    this.requiredEntitlement,
  });

  final String mediaId;
  final String deliveryReference;
  final String version;
  final String checksumSha256;
  final String? requiredEntitlement;
}

/// Server-derived entitlement state used only to decide whether an existing
/// private cache entry may still be opened. It never grants backend access.
final class MediaEntitlement {
  const MediaEntitlement({required this.key, this.expiresAt});

  final String key;
  final DateTime? expiresAt;

  bool isActiveAt(DateTime at) =>
      expiresAt == null || expiresAt!.toUtc().isAfter(at.toUtc());
}

/// The authenticated/anonymous Supabase owner and its current authoritative
/// entitlement projection. Every remote cache entry is bound to one owner.
final class MediaAccessScope {
  MediaAccessScope({
    required this.ownerId,
    Iterable<MediaEntitlement> entitlements = const [],
  }) : assert(ownerId != ''),
       entitlements = Map.unmodifiable({
         for (final entitlement in entitlements) entitlement.key: entitlement,
       });

  final String ownerId;
  final Map<String, MediaEntitlement> entitlements;

  bool canAccess(MediaDelivery media, DateTime at) {
    final key = media.requiredEntitlement;
    if (key == null) return true;
    return entitlements[key]?.isActiveAt(at) ?? false;
  }

  bool hasActiveEntitlement(String key, DateTime at) =>
      entitlements[key]?.isActiveAt(at) ?? false;
}

final class MediaAuthorizationRequest {
  const MediaAuthorizationRequest({
    required this.deliveryReference,
    required this.accessScope,
  });

  final String deliveryReference;
  final MediaAccessScope accessScope;
}

/// A URL capability returned only by a trusted authorization service. It is
/// deliberately not serializable and must not be put in exceptions or logs.
final class EphemeralMediaUrl {
  const EphemeralMediaUrl({required this.value, required this.expiresAt});

  final Uri value;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime at) => !expiresAt.toUtc().isAfter(at.toUtc());
}

abstract interface class TrustedMediaResolver {
  /// Authorizes this one opaque delivery reference. Implementations must apply
  /// account, entitlement, and license policy before returning the capability.
  Future<EphemeralMediaUrl> resolve(MediaAuthorizationRequest request);
}

abstract interface class MediaDownloadClient {
  /// Downloads using an ephemeral capability. Implementations must not retain
  /// the capability after this future completes.
  Future<Uint8List> download(EphemeralMediaUrl authorization);
}

abstract interface class MediaFileStore {
  Future<bool> exists(String path);
  Future<Uint8List> read(String path);
  Future<String> writeTemporary(Uint8List bytes);
  Future<void> commitTemporary({
    required String temporaryPath,
    required String path,
  });
  Future<void> delete(String path);

  /// Free bytes when the platform can report them, otherwise null. A real
  /// out-of-space write must still throw [MediaStorageException].
  Future<int?> availableBytes();

  /// Returns a deterministic application-owned cache location. It must not
  /// include a delivery reference or resolved URL.
  String pathFor({
    required String ownerId,
    required String mediaId,
    required String checksumSha256,
  });
}

/// A privacy-safe typed storage failure. Raw OS paths/messages must not escape
/// into analytics, crash breadcrumbs, or user-facing errors.
final class MediaStorageException implements Exception {
  const MediaStorageException();
}

enum MediaNetwork { offline, cellular, wifi }

abstract interface class MediaNetworkStatus {
  Future<MediaNetwork> currentNetwork();
}

final class CachedMedia {
  const CachedMedia({
    required this.ownerId,
    required this.mediaId,
    required this.path,
    required this.version,
    required this.checksumSha256,
    required this.requiredEntitlement,
    required this.byteSize,
    required this.lastVerifiedAccess,
  });

  final String ownerId;
  final String mediaId;
  final String path;
  final String version;
  final String checksumSha256;
  final String? requiredEntitlement;
  final int byteSize;
  final DateTime lastVerifiedAccess;
}

abstract interface class MediaCacheIndex {
  Future<CachedMedia?> find({required String ownerId, required String mediaId});
  Future<List<CachedMedia>> allVerifiedByLeastRecentAccess();
  Future<void> put(CachedMedia media);
  Future<void> remove({required String ownerId, required String mediaId});
  Future<void> purgeOwner(String ownerId);
  Future<void> touch({
    required String ownerId,
    required String mediaId,
    required DateTime at,
  });
}

enum MediaFailureCode {
  networkRestricted,
  offline,
  authorizationUnavailable,
  entitlementRequired,
  downloadFailed,
  cacheWriteFailed,
  integrityMismatch,
}

sealed class MediaPreparationResult {
  const MediaPreparationResult();
}

final class MediaPrepared extends MediaPreparationResult {
  const MediaPrepared({
    required this.mediaId,
    required this.localPath,
    required this.fromCache,
  });

  final String mediaId;
  final String localPath;
  final bool fromCache;
}

/// Recoverable storage state. Existing verified files have not been removed
/// except for eligible LRU entries selected to make room.
final class MediaStorageNeeded extends MediaPreparationResult {
  const MediaStorageNeeded({
    required this.mediaId,
    required this.requiredBytes,
  });

  final String mediaId;
  final int requiredBytes;
}

final class MediaUnavailable extends MediaPreparationResult {
  const MediaUnavailable({
    required this.mediaId,
    required this.code,
    this.canRetry = true,
  });

  final String mediaId;
  final MediaFailureCode code;
  final bool canRetry;
}

final class RoutineMediaPreparation {
  const RoutineMediaPreparation(this.results);

  final Map<String, MediaPreparationResult> results;

  bool get allReady =>
      results.values.every((result) => result is MediaPrepared);
}
