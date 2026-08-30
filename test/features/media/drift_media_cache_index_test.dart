import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/media/data/drift_media_cache_index.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

void main() {
  test(
    'isolates the same media id by owner and purges one owner only',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final now = DateTime.utc(2026, 8, 30, 12);
      await database
          .into(database.localExercises)
          .insert(
            LocalExercisesCompanion.insert(
              id: 'exercise-1',
              status: 'published',
              accessTier: 'premium',
              difficulty: 'beginner',
              safetyApproved: true,
              updatedAt: now,
            ),
          );
      await database
          .into(database.localMediaAssets)
          .insert(
            LocalMediaAssetsCompanion.insert(
              id: 'media-1',
              exerciseId: 'exercise-1',
              mediaType: 'video',
              deliveryReference: '00000000-0000-4000-8000-000000000001',
              mimeType: 'video/mp4',
              checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              status: 'published',
              updatedAt: now,
            ),
          );
      final index = DriftMediaCacheIndex(database);
      for (final owner in ['owner-a', 'owner-b']) {
        await index.put(
          CachedMedia(
            ownerId: owner,
            mediaId: 'media-1',
            path: 'cache/$owner/media-1',
            version: 'v1',
            checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            requiredEntitlement: 'premium',
            byteSize: 100,
            lastVerifiedAccess: now,
          ),
        );
      }

      expect(
        await index.find(ownerId: 'owner-a', mediaId: 'media-1'),
        isNotNull,
      );
      expect(
        await index.find(ownerId: 'owner-b', mediaId: 'media-1'),
        isNotNull,
      );

      await index.purgeOwner('owner-a');

      expect(await index.find(ownerId: 'owner-a', mediaId: 'media-1'), isNull);
      expect(
        await index.find(ownerId: 'owner-b', mediaId: 'media-1'),
        isNotNull,
      );
    },
  );
}
