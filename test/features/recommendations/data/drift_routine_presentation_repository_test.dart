import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/data/drift_routine_presentation_repository.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  DriftRoutinePresentationRepository repository() =>
      DriftRoutinePresentationRepository(database);

  test('loads localized name, summary, movements and taxonomy', () async {
    final presentation = await repository().load('raha_rt_000001', 'en');
    expect(presentation, isNotNull);
    expect(presentation!.name, 'Seated neck and shoulders reset');
    expect(presentation.summary, 'A short seated mobility routine.');
    expect(presentation.movementCount, 2);
    expect(presentation.movements, const [
      MovementPreviewEntry(name: 'Seated neck release', durationSeconds: 150),
      MovementPreviewEntry(name: 'Seated shoulder rolls', durationSeconds: 150),
    ]);
    expect(presentation.difficulty, DifficultyLevel.beginner);
    expect(presentation.estimatedDurationSeconds, 300);
    expect(presentation.positions, {'seated'});
    expect(presentation.equipment, {'body_weight'});
  });

  test('loads Arabic content in the requested locale', () async {
    final presentation = await repository().load('raha_rt_000001', 'ar');
    expect(presentation!.name, 'استراحة للرقبة والكتفين');
    expect(presentation.movements.first.name, 'تحرير الرقبة');
  });

  test('falls back to English for an unsupported locale', () async {
    final presentation = await repository().load('raha_rt_000001', 'fr');
    expect(presentation!.name, 'Seated neck and shoulders reset');
    expect(presentation.movements.first.name, 'Seated neck release');
  });

  test('returns null for a missing routine', () async {
    expect(await repository().load('raha_rt_missing', 'en'), isNull);
  });

  test('returns null for a retired routine', () async {
    expect(await repository().load('raha_rt_000002', 'en'), isNull);
  });
}

Future<void> _seed(AppDatabase db, DateTime now) async {
  for (final (key, kind) in const [
    ('neck', 'body_area'),
    ('shoulders', 'body_area'),
    ('ease_stiffness', 'goal'),
    ('seated', 'position'),
    ('floor', 'position'),
    ('body_weight', 'equipment'),
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
        safetyApproved: true,
        updatedAt: now,
      ),
    ]),
  );

  await db.batch(
    (b) => b.insertAll(db.localExerciseTranslations, [
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'raha_ex_000001',
        locale: 'en',
        name: 'Seated neck release',
      ),
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'raha_ex_000001',
        locale: 'ar',
        name: 'تحرير الرقبة',
      ),
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'raha_ex_000002',
        locale: 'en',
        name: 'Seated shoulder rolls',
      ),
      LocalExerciseTranslationsCompanion.insert(
        exerciseId: 'raha_ex_000002',
        locale: 'ar',
        name: 'دوائر الكتفين',
      ),
    ]),
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
      status: 'retired',
      accessTier: 'free',
      difficulty: 'beginner',
      estimatedDurationSeconds: 300,
      version: 1,
      updatedAt: now,
    ),
  ]) {
    await db.into(db.localRoutines).insert(routine);
  }

  await db.batch(
    (b) => b.insertAll(db.localRoutineTranslations, [
      LocalRoutineTranslationsCompanion.insert(
        routineId: 'raha_rt_000001',
        locale: 'en',
        name: 'Seated neck and shoulders reset',
        summary: 'A short seated mobility routine.',
      ),
      LocalRoutineTranslationsCompanion.insert(
        routineId: 'raha_rt_000001',
        locale: 'ar',
        name: 'استراحة للرقبة والكتفين',
        summary: 'روتين حركة قصير أثناء الجلوس.',
      ),
    ]),
  );

  await db.batch(
    (b) => b.insertAll(db.localRoutineSteps, [
      LocalRoutineStepsCompanion.insert(
        id: 'step_000001',
        routineId: 'raha_rt_000001',
        exerciseId: 'raha_ex_000001',
        position: 1,
        durationSeconds: 150,
      ),
      LocalRoutineStepsCompanion.insert(
        id: 'step_000002',
        routineId: 'raha_rt_000001',
        exerciseId: 'raha_ex_000002',
        position: 2,
        durationSeconds: 150,
      ),
    ]),
  );

  for (final (routineId, taxonomyKey) in [
    ('raha_rt_000001', 'seated'),
    ('raha_rt_000001', 'body_weight'),
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
