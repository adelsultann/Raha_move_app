import 'package:raha_move/features/media/domain/media_delivery.dart';

final class MediaCachePurgeException implements Exception {
  const MediaCachePurgeException();
}

/// Security boundary called by authentication on logout/account switch and by
/// entitlement refresh before private media remains available.
final class MediaCacheLifecycle {
  const MediaCacheLifecycle({required this.cache, required this.files});

  final MediaCacheIndex cache;
  final MediaFileStore files;

  /// Startup recovery. It removes cache partitions that do not belong to the
  /// live session, including every remote partition when signed out.
  Future<void> reconcileCurrentOwner(String? currentOwnerId) async {
    final entries = await cache.allVerifiedByLeastRecentAccess();
    final staleOwners = entries
        .map((entry) => entry.ownerId)
        .where((ownerId) => ownerId != currentOwnerId)
        .toSet();
    for (final ownerId in staleOwners) {
      await purgeOwner(ownerId);
    }
  }

  Future<void> onSessionChanged({
    required String? previousOwnerId,
    required String? currentOwnerId,
  }) async {
    if (previousOwnerId == null || previousOwnerId == currentOwnerId) return;
    await purgeOwner(previousOwnerId);
  }

  Future<void> purgeOwner(String ownerId) async {
    final entries = await cache.allVerifiedByLeastRecentAccess();
    final owned = entries.where((entry) => entry.ownerId == ownerId);
    try {
      for (final entry in owned) {
        if (await files.exists(entry.path)) await files.delete(entry.path);
        await cache.remove(ownerId: ownerId, mediaId: entry.mediaId);
      }
      await cache.purgeOwner(ownerId);
    } catch (_) {
      // Fail closed: authentication/account switching must retry purge instead
      // of silently forgetting metadata while private bytes remain on disk.
      throw const MediaCachePurgeException();
    }
  }
}
