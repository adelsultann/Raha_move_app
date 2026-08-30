import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';

void main() {
  final now = DateTime.utc(2026, 8, 29, 12);

  test(
    'migrates v3 media delivery column and release/step columns to v4',
    () async {
      final migrated = AppDatabase(_v3FixtureExecutor(now));

      final media = await (migrated.select(
        migrated.localMediaAssets,
      )..where((row) => row.id.equals('media-1'))).getSingle();
      expect(media.deliveryReference, 'opaque-ref-1');

      final release = await (migrated.select(
        migrated.localContentReleases,
      )..where((row) => row.id.equals('1'))).getSingle();
      expect(release.version, '');
      expect(release.contractVersion, 'raha-content-release-v1');
      expect(release.publishedAt, isNull);
      expect(release.manifestChecksum, isNotEmpty);
      expect(release.isCurrent, isTrue);

      final step = await (migrated.select(
        migrated.localRoutineSteps,
      )..where((row) => row.id.equals('step-1'))).getSingle();
      expect(step.status, 'published');

      await migrated.close();
    },
  );

  test('enforces the opaque delivery-reference constraint in v4', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final seed = now;
    await database
        .into(database.localExercises)
        .insert(
          LocalExercisesCompanion.insert(
            id: 'exercise-1',
            status: 'published',
            accessTier: 'free',
            difficulty: 'beginner',
            safetyApproved: true,
            updatedAt: seed,
          ),
        );

    await expectLater(
      database
          .into(database.localMediaAssets)
          .insert(
            LocalMediaAssetsCompanion.insert(
              id: 'media-bad',
              exerciseId: 'exercise-1',
              mediaType: 'video',
              deliveryReference: 'https://example.com/video.mp4',
              mimeType: 'video/mp4',
              checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              status: 'published',
              updatedAt: seed,
            ),
          ),
      throwsA(isA<Exception>()),
    );

    await database
        .into(database.localMediaAssets)
        .insert(
          LocalMediaAssetsCompanion.insert(
            id: 'media-good',
            exerciseId: 'exercise-1',
            mediaType: 'video',
            deliveryReference: '0a000000-0000-0000-0000-000000000001',
            mimeType: 'video/mp4',
            checksumSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            status: 'published',
            updatedAt: seed,
          ),
        );
    expect(
      await database.select(database.localMediaAssets).get(),
      hasLength(1),
    );
    await database.close();
  });
}

NativeDatabase _v3FixtureExecutor(DateTime now) => NativeDatabase.memory(
  setup: (raw) {
    final millis = now.millisecondsSinceEpoch;
    raw.execute(
      'CREATE TABLE local_exercises ('
      'id TEXT NOT NULL PRIMARY KEY, status TEXT NOT NULL, '
      'access_tier TEXT NOT NULL, difficulty TEXT NOT NULL, '
      'safety_approved INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
    );
    raw.execute(
      "INSERT INTO local_exercises VALUES ('exercise-1', 'published', 'free', 'beginner', 1, $millis)",
    );
    raw.execute(
      'CREATE TABLE local_routines ('
      'id TEXT NOT NULL PRIMARY KEY, status TEXT NOT NULL, '
      'access_tier TEXT NOT NULL, difficulty TEXT NOT NULL, '
      'estimated_duration_seconds INTEGER NOT NULL, version INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL)',
    );
    raw.execute(
      "INSERT INTO local_routines VALUES ('routine-1', 'published', 'free', 'beginner', 60, 1, $millis)",
    );
    raw.execute(
      'CREATE TABLE local_routine_steps ('
      'id TEXT NOT NULL PRIMARY KEY, routine_id TEXT NOT NULL, '
      'exercise_id TEXT NOT NULL, position INTEGER NOT NULL, '
      'duration_seconds INTEGER NOT NULL, rest_after_seconds INTEGER NOT NULL DEFAULT 0, '
      'is_optional INTEGER NOT NULL DEFAULT 0)',
    );
    raw.execute(
      "INSERT INTO local_routine_steps VALUES ('step-1', 'routine-1', 'exercise-1', 1, 60, 0, 0)",
    );
    raw.execute(
      'CREATE TABLE local_media_assets ('
      'id TEXT NOT NULL PRIMARY KEY, exercise_id TEXT NOT NULL, media_type TEXT NOT NULL, '
      'storage_key TEXT NOT NULL, mime_type TEXT NOT NULL, checksum_sha256 TEXT NOT NULL, '
      'status TEXT NOT NULL, is_preferred INTEGER NOT NULL DEFAULT 0, '
      'width INTEGER NULL, height INTEGER NULL, duration_ms INTEGER NULL, updated_at INTEGER NOT NULL)',
    );
    raw.execute(
      "INSERT INTO local_media_assets VALUES ('media-1', 'exercise-1', 'video', 'opaque-ref-1', 'video/mp4', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'published', 1, 720, 720, 3000, $millis)",
    );
    raw.execute(
      'CREATE TABLE local_content_releases ('
      'id TEXT NOT NULL PRIMARY KEY, manifest_checksum TEXT NOT NULL, '
      'minimum_app_version TEXT NULL, applied_at INTEGER NOT NULL, '
      'is_current INTEGER NOT NULL DEFAULT 0)',
    );
    raw.execute(
      "INSERT INTO local_content_releases VALUES ('1', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', '1.0.0', $millis, 1)",
    );
    raw.execute('PRAGMA user_version = 3');
  },
);
