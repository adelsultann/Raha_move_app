import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/data/drift_recommendation_catalog.dart';

import '../../exercise_library/data/release_fixture.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('maps a published routine into a candidate snapshot', () async {
    final release = ContentReleaseRepository(database, clock: () => now);
    await release.applyRelease(
      envelopeFor(minimalValidManifest()),
      appVersion: '1.0.0',
    );

    final candidates = await DriftRecommendationCatalog(database)
        .loadPublishedCandidates();

    expect(candidates, hasLength(1));
    final candidate = candidates.single;
    expect(candidate.routineId, 'raha_rt_000001');
    expect(candidate.status, ContentStatus.published);
    expect(candidate.accessTier, AccessTier.free);
    expect(candidate.difficulty, DifficultyLevel.beginner);
    expect(candidate.estimatedDurationSeconds, 30);
    expect(candidate.bodyAreas, {'neck'});
    expect(candidate.goals, {'ease_stiffness'});
    expect(candidate.positions, {'seated'});
    expect(candidate.exerciseIds, {'raha_ex_000001'});
    expect(candidate.exercisesSafetyApproved, isTrue);
    expect(candidate.exercisesHavePlayableMedia, isTrue);
    expect(candidate.minimumAppVersion, '1.0.0');
  });

  test('maps multiple taxonomies and flags unavailable candidates', () async {
    await _seedCatalog(database, now);

    final candidates = await DriftRecommendationCatalog(database)
        .loadPublishedCandidates();
    final byId = {for (final c in candidates) c.routineId: c};

    // Retired routine is excluded from the published read.
    expect(byId.keys, isNot(contains('raha_rt_000003')));
    expect(byId, hasLength(2));

    final full = byId['raha_rt_000001']!;
    expect(full.bodyAreas, {'neck', 'shoulders'});
    expect(full.goals, {'ease_stiffness'});
    expect(full.positions, {'seated'});
    expect(full.exerciseIds, {'raha_ex_000001'});
    expect(full.exercisesSafetyApproved, isTrue);
    expect(full.exercisesHavePlayableMedia, isTrue);

    final unsafe = byId['raha_rt_000002']!;
    expect(unsafe.bodyAreas, {'hips'});
    expect(unsafe.goals, {'relax'});
    expect(unsafe.positions, {'floor'});
    expect(unsafe.exerciseIds, {'raha_ex_000002'});
    expect(unsafe.exercisesSafetyApproved, isFalse);
    expect(unsafe.exercisesHavePlayableMedia, isFalse);
  });
}

Future<void> _seedCatalog(AppDatabase db, DateTime now) async {
  for (final (key, kind) in const [
    ('neck', 'body_area'),
    ('shoulders', 'body_area'),
    ('hips', 'body_area'),
    ('ease_stiffness', 'goal'),
    ('relax', 'goal'),
    ('seated', 'position'),
    ('floor', 'position'),
  ]) {
    await db
        .into(db.localTaxonomies)
        .insert(LocalTaxonomiesCompanion.insert(key: key, kind: kind));
  }

  await db.batch(
    (b) => b.insertAll(db.localExercises, [
      LocalExercisesCompanion.insert(
        id: 'raha_ex_000001',
        status: 'published',
        accessTier: 'free',
        difficulty: 'beginner',
        safetyApproved: true,
        updatedAt: now,
      ),
      LocalExercisesCompanion.insert(
        id: 'raha_ex_000002',
        status: 'published',
        accessTier: 'free',
        difficulty: 'beginner',
        safetyApproved: false,
        updatedAt: now,
      ),
    ]),
  );

  await db
      .into(db.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: 'media_000001',
          exerciseId: 'raha_ex_000001',
          mediaType: 'video',
          deliveryReference: 'ref_000001',
          mimeType: 'video/mp4',
          checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          status: 'published',
          isPreferred: const Value(true),
          updatedAt: now,
        ),
      );

  for (final routine in [
    LocalRoutinesCompanion.insert(
      id: 'raha_rt_000001',
      status: 'published',
      accessTier: 'free',
      difficulty: 'beginner',
      estimatedDurationSeconds: 300,
      version: 1,
      updatedAt: now,
    ),
    LocalRoutinesCompanion.insert(
      id: 'raha_rt_000002',
      status: 'published',
      accessTier: 'free',
      difficulty: 'beginner',
      estimatedDurationSeconds: 120,
      version: 1,
      updatedAt: now,
    ),
    LocalRoutinesCompanion.insert(
      id: 'raha_rt_000003',
      status: 'retired',
      accessTier: 'free',
      difficulty: 'beginner',
      estimatedDurationSeconds: 120,
      version: 1,
      updatedAt: now,
    ),
  ]) {
    await db.into(db.localRoutines).insert(routine);
  }

  await db.batch(
    (b) => b.insertAll(db.localRoutineSteps, [
      LocalRoutineStepsCompanion.insert(
        id: 'step_000001',
        routineId: 'raha_rt_000001',
        exerciseId: 'raha_ex_000001',
        position: 1,
        durationSeconds: 300,
      ),
      LocalRoutineStepsCompanion.insert(
        id: 'step_000002',
        routineId: 'raha_rt_000002',
        exerciseId: 'raha_ex_000002',
        position: 1,
        durationSeconds: 120,
      ),
    ]),
  );

  for (final (routineId, taxonomyKey) in [
    ('raha_rt_000001', 'neck'),
    ('raha_rt_000001', 'shoulders'),
    ('raha_rt_000001', 'ease_stiffness'),
    ('raha_rt_000001', 'seated'),
    ('raha_rt_000002', 'hips'),
    ('raha_rt_000002', 'relax'),
    ('raha_rt_000002', 'floor'),
  ]) {
    await db
        .into(db.localRoutineTaxonomies)
        .insert(
          LocalRoutineTaxonomiesCompanion.insert(
            routineId: routineId,
            taxonomyKey: taxonomyKey,
          ),
        );
  }
}
