import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/explore/data/drift_explore_repository.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';

void main() {
  late AppDatabase database;
  late DriftExploreRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftExploreRepository(database);
    await _seed(database);
  });
  tearDown(() => database.close());

  test(
    'reads published local contexts and intersects every selected filter',
    () async {
      expect(
        (await repository.categories('en')).map((category) => category.key),
        ['desk_break'],
      );

      final matches = await repository.browse(
        locale: 'en',
        context: 'desk_break',
        filters: const ExploreFilters(
          durationsMinutes: {5},
          bodyAreas: {'shoulders'},
          positions: {'seated'},
          difficulties: {DifficultyLevel.beginner},
          equipment: {'body_weight'},
        ),
      );
      expect(matches.single.routineId, 'routine_ok');

      final empty = await repository.browse(
        locale: 'en',
        context: 'desk_break',
        filters: const ExploreFilters(positions: {'floor'}),
      );
      expect(empty, isEmpty);
      expect(
        (await repository.browse(
          locale: 'en',
          filters: const ExploreFilters(),
        )).map((routine) => routine.routineId),
        ['routine_ok'],
      );
    },
  );

  test(
    'blocks Details start when a scheduled exercise has no playable media',
    () async {
      await (database.update(database.localMediaAssets)
            ..where((row) => row.id.equals('media')))
          .write(const LocalMediaAssetsCompanion(status: Value('retired')));
      final details = await repository.details('routine_ok', 'en');
      expect(
        details!.eligibility,
        const RoutineStartEligibility.blocked(RoutineStartBlock.unavailable),
      );
    },
  );

  test(
    'details are local, Arabic-resolved, and fail closed for access',
    () async {
      final details = await repository.details('routine_ok', 'ar');
      expect(details!.presentation.name, 'استراحة الكتفين');
      expect(details.eligibility, isA<RoutineStartAllowed>());

      await (database.update(database.localRoutines)
            ..where((row) => row.id.equals('routine_ok')))
          .write(const LocalRoutinesCompanion(accessTier: Value('premium')));
      final blocked = await repository.details('routine_ok', 'en');
      expect(
        blocked!.eligibility,
        const RoutineStartEligibility.blocked(RoutineStartBlock.unauthorized),
      );
    },
  );
}

Future<void> _seed(AppDatabase db) async {
  final now = DateTime.utc(2026, 9, 4);
  for (final (key, kind, label) in const [
    ('desk_break', 'routine_context', 'Desk breaks'),
    ('shoulders', 'body_area', 'Shoulders'),
    ('seated', 'position', 'Seated'),
    ('body_weight', 'equipment', 'No equipment'),
  ]) {
    await db
        .into(db.localTaxonomies)
        .insert(LocalTaxonomiesCompanion.insert(key: key, kind: kind));
    await db
        .into(db.localTaxonomyTranslations)
        .insert(
          LocalTaxonomyTranslationsCompanion.insert(
            taxonomyKey: key,
            locale: 'en',
            label: label,
          ),
        );
  }
  await db
      .into(db.localTaxonomyTranslations)
      .insert(
        LocalTaxonomyTranslationsCompanion.insert(
          taxonomyKey: 'desk_break',
          locale: 'ar',
          label: 'استراحات المكتب',
        ),
      );
  await db
      .into(db.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: 'exercise',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: now,
        ),
      );
  await db.batch(
    (batch) => batch.insertAll(db.localExerciseTranslations, [
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'exercise',
        locale: 'en',
        name: 'Shoulder circles',
      ),
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'exercise',
        locale: 'ar',
        name: 'دوائر الكتفين',
      ),
    ]),
  );
  await db
      .into(db.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: 'media',
          exerciseId: 'exercise',
          mediaType: 'video',
          deliveryReference: 'raha_media_000001',
          mimeType: 'video/mp4',
          checksumSha256: 'a' * 64,
          status: 'published',
          isPreferred: const Value(true),
          updatedAt: now,
        ),
      );
  await db
      .into(db.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine_ok',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 300,
          version: 1,
          updatedAt: now,
        ),
      );
  await db
      .into(db.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine_retired',
          status: 'retired',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 300,
          version: 1,
          updatedAt: now,
        ),
      );
  await db.batch(
    (batch) => batch.insertAll(db.localRoutineTranslations, [
      LocalRoutineTranslationsCompanion.insert(
        routineId: 'routine_ok',
        locale: 'en',
        name: 'Shoulder reset',
        summary: 'A calm desk break.',
      ),
      LocalRoutineTranslationsCompanion.insert(
        routineId: 'routine_ok',
        locale: 'ar',
        name: 'استراحة الكتفين',
        summary: 'استراحة مكتبية هادئة.',
      ),
    ]),
  );
  await db
      .into(db.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step',
          routineId: 'routine_ok',
          exerciseId: 'exercise',
          position: 1,
          durationSeconds: 300,
        ),
      );
  for (final key in const [
    'desk_break',
    'shoulders',
    'seated',
    'body_weight',
  ]) {
    await db
        .into(db.localRoutineTaxonomies)
        .insert(
          LocalRoutineTaxonomiesCompanion.insert(
            routineId: 'routine_ok',
            taxonomyKey: key,
          ),
        );
  }
}
