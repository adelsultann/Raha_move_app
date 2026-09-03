import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/today/data/drift_today_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTodayRepository repository;

  Future<void> addTranslation(String locale, String name) => database
      .into(database.localRoutineTranslations)
      .insert(
        LocalRoutineTranslationsCompanion.insert(
          routineId: 'routine-1',
          locale: locale,
          name: name,
          summary: 'summary',
        ),
      );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTodayRepository(database);
    await database
        .into(database.localRoutines)
        .insert(
          LocalRoutinesCompanion.insert(
            id: 'routine-1',
            status: 'published',
            accessTier: 'free',
            difficulty: 'beginner',
            estimatedDurationSeconds: 300,
            version: 1,
            updatedAt: DateTime.utc(2026, 9, 8),
          ),
        );
  });

  tearDown(() => database.close());

  test('uses Arabic when available', () async {
    await addTranslation('ar', 'استراحة المكتب');

    expect(
      await repository.routineName(routineId: 'routine-1', locale: 'ar'),
      'استراحة المكتب',
    );
  });

  test(
    'falls back to English when the requested locale is unavailable',
    () async {
      await addTranslation('en', 'Desk reset');

      expect(
        await repository.routineName(routineId: 'routine-1', locale: 'ar'),
        'Desk reset',
      );
    },
  );
}
