import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/recommendations/data/drift_recommendation_history.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_history.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  test('loads recent completed attempts and discomfort exercises', () async {
    final history = await DriftRecommendationHistory(database)
        .loadFor('user-1');

    expect(history.recentAttempts, [
      RecentRoutineAttempt(
        routineId: 'raha_rt_000001',
        completedAt: now.toUtc(),
      ),
    ]);
    expect(history.uncomfortableExerciseIds, {'raha_ex_000001'});
  });

  test('ignores other users and non-less_comfortable feedback', () async {
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            userId: 'user-2',
            preferredLocale: 'en',
            timezone: 'Asia/Riyadh',
            weeklyGoalDays: 3,
            localUpdatedAt: now,
          ),
        );

    await database
        .into(database.localRoutineSessions)
        .insert(
          LocalRoutineSessionsCompanion.insert(
            id: 'session-other',
            userId: 'user-2',
            routineId: 'raha_rt_000001',
            routineVersion: 1,
            status: 'completed',
            startedAt: now.subtract(const Duration(minutes: 5)),
            completedAt: Value(now),
            targetDurationSeconds: 300,
            actualDurationSeconds: 240,
            totalSteps: 2,
            completionPolicyVersion: 'completion_v1',
            source: 'recommendation',
            localUpdatedAt: now,
          ),
        );

    final history = await DriftRecommendationHistory(database)
        .loadFor('user-1');

    expect(history.recentAttempts, hasLength(1));
    expect(history.uncomfortableExerciseIds, {'raha_ex_000001'});
  });
}

Future<void> _seed(AppDatabase db, DateTime now) async {
  await db
      .into(db.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );

  await db
      .into(db.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: 'raha_ex_000001',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: now,
        ),
      );

  await db
      .into(db.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'raha_rt_000001',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 300,
          version: 1,
          updatedAt: now,
        ),
      );

  await db
      .into(db.localRoutineSessions)
      .insert(
        LocalRoutineSessionsCompanion.insert(
          id: 'session-1',
          userId: 'user-1',
          routineId: 'raha_rt_000001',
          routineVersion: 1,
          status: 'completed',
          startedAt: now.subtract(const Duration(minutes: 5)),
          completedAt: Value(now),
          targetDurationSeconds: 300,
          actualDurationSeconds: 240,
          totalSteps: 2,
          completionPolicyVersion: 'completion_v1',
          source: 'recommendation',
          localUpdatedAt: now,
        ),
      );

  await db
      .into(db.localSessionFeedback)
      .insert(
        LocalSessionFeedbackCompanion.insert(
          sessionId: 'session-1',
          userId: 'user-1',
          rating: 'less_comfortable',
          uncomfortableExerciseId: const Value('raha_ex_000001'),
          createdAt: now,
          localUpdatedAt: now,
        ),
      );
}
