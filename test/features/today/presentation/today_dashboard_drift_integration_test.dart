import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/today/data/drift_today_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTodayRepository repository;
  final now = DateTime.utc(2026, 9, 8, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTodayRepository(database);
    await _seed(database, now);
  });
  tearDown(() => database.close());

  test(
    'local completion write notifies Today and is immediately readable',
    () async {
      final changes = repository
          .watchChanges(userId: 'guest-1')
          .asBroadcastStream();
      await changes.first;

      final nextChange = changes.first;
      await database
          .into(database.localRoutineSessions)
          .insert(
            LocalRoutineSessionsCompanion.insert(
              id: 'completed-session',
              userId: 'guest-1',
              routineId: 'routine-1',
              routineVersion: 1,
              status: 'completed',
              startedAt: now,
              completedAt: Value(now),
              targetDurationSeconds: 60,
              actualDurationSeconds: 60,
              totalSteps: 1,
              stepsCompleted: const Value(1),
              completionPolicyVersion: 'mvp_v1',
              source: 'recommendation',
              localUpdatedAt: now,
            ),
          );
      await nextChange;

      final completed = await repository.latestCompletedRoutine(
        userId: 'guest-1',
        locale: 'en',
      );
      expect(completed?.name, 'Desk reset');
      expect(completed?.sessionId, 'completed-session');
    },
  );

  test('resumable routine names use Arabic then English fallback', () async {
    await _translation(database, locale: 'ar', name: 'استراحة المكتب');
    expect(
      await repository.routineName(routineId: 'routine-1', locale: 'ar'),
      'استراحة المكتب',
    );

    await database.delete(database.localRoutineTranslations).go();
    await _translation(database, locale: 'en', name: 'Desk reset');
    expect(
      await repository.routineName(routineId: 'routine-1', locale: 'ar'),
      'Desk reset',
    );
  });
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'guest-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 60,
          version: 1,
          updatedAt: now,
        ),
      );
  await _translation(database, locale: 'en', name: 'Desk reset');
}

Future<void> _translation(
  AppDatabase database, {
  required String locale,
  required String name,
}) => database
    .into(database.localRoutineTranslations)
    .insert(
      LocalRoutineTranslationsCompanion.insert(
        routineId: 'routine-1',
        locale: locale,
        name: name,
        summary: 'summary',
      ),
    );
