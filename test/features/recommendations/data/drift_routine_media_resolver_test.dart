import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:raha_move/features/recommendations/data/drift_routine_media_resolver.dart';

import '../../exercise_library/data/release_fixture.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await ContentReleaseRepository(
      database,
      clock: () => now,
    ).applyRelease(envelopeFor(minimalValidManifest()), appVersion: '1.0.0');
  });

  tearDown(() => database.close());

  DriftRoutineMediaResolver resolver() => DriftRoutineMediaResolver(database);

  test(
    'resolves the preferred playable media with the current release version',
    () async {
      final resolution = await resolver().resolve('raha_rt_000001');

      expect(resolution.missingExerciseIds, isEmpty);
      expect(resolution.media, hasLength(1));
      final delivery = resolution.media.single;
      expect(delivery.mediaId, '02000000-0000-0000-0000-000000000001');
      expect(
        delivery.deliveryReference,
        '0a000000-0000-0000-0000-000000000001',
      );
      expect(delivery.version, 'release-1');
      expect(delivery.requiredEntitlement, isNull);
    },
  );

  test('preserves step order across multiple movements', () async {
    await _addExerciseWithMedia(
      database,
      exerciseId: 'raha_ex_000002',
      mediaId: 'media_000002',
      preferred: true,
    );
    await _addStep(database, 'step_000002', 'raha_ex_000002', position: 2);

    final resolution = await resolver().resolve('raha_rt_000001');

    expect(resolution.media.map((m) => m.mediaId), [
      '02000000-0000-0000-0000-000000000001',
      'media_000002',
    ]);
  });

  test(
    'falls back to an alternate playable asset when preferred is pending',
    () async {
      await _addExerciseWithMedia(
        database,
        exerciseId: 'raha_ex_000002',
        mediaId: 'media_pending',
        preferred: true,
        status: 'pending',
        checksum: '',
      );
      await _addMedia(
        database,
        exerciseId: 'raha_ex_000002',
        mediaId: 'media_fallback',
        preferred: false,
      );
      await _addStep(database, 'step_000002', 'raha_ex_000002', position: 2);

      final resolution = await resolver().resolve('raha_rt_000001');

      expect(resolution.missingExerciseIds, isEmpty);
      expect(
        resolution.media.map((m) => m.mediaId),
        contains('media_fallback'),
      );
      expect(
        resolution.media.map((m) => m.mediaId),
        isNot(contains('media_pending')),
      );
    },
  );

  test('reports a missing step when no playable media exists', () async {
    await _addExerciseWithMedia(
      database,
      exerciseId: 'raha_ex_000002',
      mediaId: 'media_pending',
      preferred: true,
      status: 'pending',
      checksum: '',
    );
    await _addStep(database, 'step_000002', 'raha_ex_000002', position: 2);

    final resolution = await resolver().resolve('raha_rt_000001');

    expect(resolution.missingExerciseIds, ['raha_ex_000002']);
    // The first step still resolves; the missing step is reported separately.
    expect(resolution.media, hasLength(1));
  });

  test('marks premium media with the premium entitlement', () async {
    await (database.update(database.localExercises)
          ..where((e) => e.id.equals('raha_ex_000001')))
        .write(const LocalExercisesCompanion(accessTier: Value('premium')));

    final resolution = await resolver().resolve('raha_rt_000001');

    expect(resolution.media.single.requiredEntitlement, 'premium');
  });

  test('returns no media for a missing or retired routine', () async {
    expect((await resolver().resolve('raha_rt_missing')).media, isEmpty);
  });
}

Future<void> _addExerciseWithMedia(
  AppDatabase database, {
  required String exerciseId,
  required String mediaId,
  required bool preferred,
  String status = 'published',
  String checksum =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
}) async {
  await database
      .into(database.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: exerciseId,
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: DateTime.utc(2026, 8, 30, 12),
        ),
      );
  await _addMedia(
    database,
    exerciseId: exerciseId,
    mediaId: mediaId,
    preferred: preferred,
    status: status,
    checksum: checksum,
  );
}

Future<void> _addMedia(
  AppDatabase database, {
  required String exerciseId,
  required String mediaId,
  required bool preferred,
  String status = 'published',
  String checksum =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
}) async {
  await database
      .into(database.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: mediaId,
          exerciseId: exerciseId,
          mediaType: 'video',
          deliveryReference: 'ref-$mediaId',
          mimeType: 'video/mp4',
          checksumSha256: checksum,
          status: status,
          isPreferred: Value(preferred),
          updatedAt: DateTime.utc(2026, 8, 30, 12),
        ),
      );
}

Future<void> _addStep(
  AppDatabase database,
  String id,
  String exerciseId, {
  required int position,
}) async {
  await database
      .into(database.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: id,
          routineId: 'raha_rt_000001',
          exerciseId: exerciseId,
          position: position,
          durationSeconds: 30,
        ),
      );
}
