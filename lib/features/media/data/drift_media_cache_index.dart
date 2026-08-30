import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

/// Drift metadata index only. It never stores media bytes or authorization URLs.
final class DriftMediaCacheIndex implements MediaCacheIndex {
  DriftMediaCacheIndex(this._database);

  final AppDatabase _database;

  @override
  Future<CachedMedia?> find({
    required String ownerId,
    required String mediaId,
  }) async {
    final row =
        await (_database.select(_database.localMediaCacheEntries)..where(
              (entry) =>
                  entry.ownerId.equals(ownerId) & entry.mediaId.equals(mediaId),
            ))
            .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Future<List<CachedMedia>> allVerifiedByLeastRecentAccess() async {
    final rows =
        await (_database.select(_database.localMediaCacheEntries)
              ..where((entry) => entry.cacheState.equals('verified'))
              ..orderBy([(entry) => OrderingTerm.asc(entry.lastAccessedAt)]))
            .get();
    return rows.map(_map).toList(growable: false);
  }

  @override
  Future<void> put(CachedMedia media) => _database
      .into(_database.localMediaCacheEntries)
      .insertOnConflictUpdate(
        LocalMediaCacheEntriesCompanion.insert(
          ownerId: media.ownerId,
          mediaId: media.mediaId,
          verifiedLocalPath: media.path,
          mediaVersion: media.version,
          checksumSha256: media.checksumSha256,
          requiredEntitlement: Value(media.requiredEntitlement),
          byteSize: media.byteSize,
          cacheState: 'verified',
          lastAccessedAt: media.lastVerifiedAccess,
          verifiedAt: media.lastVerifiedAccess,
        ),
      );

  @override
  Future<void> remove({required String ownerId, required String mediaId}) =>
      (_database.delete(_database.localMediaCacheEntries)..where(
            (entry) =>
                entry.ownerId.equals(ownerId) & entry.mediaId.equals(mediaId),
          ))
          .go();

  @override
  Future<void> purgeOwner(String ownerId) => (_database.delete(
    _database.localMediaCacheEntries,
  )..where((entry) => entry.ownerId.equals(ownerId))).go();

  @override
  Future<void> touch({
    required String ownerId,
    required String mediaId,
    required DateTime at,
  }) =>
      (_database.update(_database.localMediaCacheEntries)..where(
            (entry) =>
                entry.ownerId.equals(ownerId) & entry.mediaId.equals(mediaId),
          ))
          .write(LocalMediaCacheEntriesCompanion(lastAccessedAt: Value(at)));

  CachedMedia _map(LocalMediaCacheEntry row) => CachedMedia(
    ownerId: row.ownerId,
    mediaId: row.mediaId,
    path: row.verifiedLocalPath,
    version: row.mediaVersion,
    checksumSha256: row.checksumSha256,
    requiredEntitlement: row.requiredEntitlement,
    byteSize: row.byteSize,
    lastVerifiedAccess: row.lastAccessedAt,
  );
}
