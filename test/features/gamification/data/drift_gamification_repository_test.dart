import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/gamification/data/drift_gamification_repository.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database);
  });
  tearDown(() => database.close());

  test('counts duplicate same-day qualifying sessions once but projects each award', () async {
    await _session(
      database,
      id: 'one',
      completedAt: DateTime.utc(2026, 9, 7, 8),
    );
    await _session(
      database,
      id: 'two',
      completedAt: DateTime.utc(2026, 9, 7, 18),
    );

    final progress = await _repository(
      database,
      now: DateTime.utc(2026, 9, 8),
    ).currentWeeklyGoal();

    expect(progress.movementDays, 1);
    expect(progress.pendingPointAwards, 2);
    expect(progress.isAuthoritative, isFalse);
  });

  test(
    'reads only server-confirmed achievement awards from its projection',
    () async {
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'achievements',
              payloadJson: jsonEncode({
                'catalog': [
                  {
                    'id': 'achievement-1',
                    'key': 'first_step',
                    'category': 'getting_started',
                    'criteria_version': 1,
                    'criteria': {'rule_version': 'achievement_sessions_v1'},
                    'icon_key': 'first_step',
                    'status': 'published',
                    'translations': {
                      'en': {
                        'title': 'First Step',
                        'description': 'First routine.',
                      },
                      'ar': {
                        'title': 'خطوتك الأولى',
                        'description': 'روتينك الأول.',
                      },
                    },
                  },
                ],
                'earned': [
                  {
                    'achievement_id': 'achievement-1',
                    'earned_at': '2026-09-12T09:00:00Z',
                    'source_id': 'session-confirmed',
                    'criteria_version': 1,
                  },
                ],
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 12, 9),
            ),
          );

      final achievements = await _repository(
        database,
        now: DateTime.utc(2026, 9, 12, 10),
      ).achievements();

      expect(achievements, hasLength(1));
      expect(achievements.single.isEarned, isTrue);
      expect(achievements.single.sourceId, 'session-confirmed');
      expect(achievements.single.translationFor('ar')?.title, 'خطوتك الأولى');
    },
  );

  test('reconciles local estimates with the server weekly projection without double counting', () async {
    await _session(
      database,
      id: 'pending',
      completedAt: DateTime.utc(2026, 9, 7, 8),
    );
    await database
        .into(database.localProgressProjections)
        .insert(
          LocalProgressProjectionsCompanion.insert(
            userId: 'user-1',
            projectionType: 'weekly_progress',
            payloadJson: jsonEncode({
              // Actual server shape: timestamptz plus the user's IANA timezone.
              // This Sunday UTC instant is Monday in Asia/Riyadh.
              'week_start': '2026-08-30T21:00:00+00:00',
              'timezone': 'Asia/Riyadh',
              'goal_days': 3,
              'movement_days': 1,
            }),
            serverUpdatedAt: DateTime.utc(2026, 8, 31, 1),
          ),
        );
    await database
        .into(database.localProgressProjections)
        .insert(
          LocalProgressProjectionsCompanion.insert(
            userId: 'user-1',
            projectionType: 'points',
            // Actual server points projection: an append-only ledger array.
            payloadJson: jsonEncode([
              {
                'id': 'ledger-1',
                'points': 10,
                'rule_version': 'points_completion_v1',
                'source_type': 'session',
                'source_id': 'pending',
              },
            ]),
            serverUpdatedAt: DateTime.utc(2026, 9, 7, 9),
          ),
        );

    final progress = await _repository(
      database,
      now: DateTime.utc(2026, 8, 31, 12),
    ).currentWeeklyGoal();

    expect(progress.isAuthoritative, isTrue);
    expect(progress.movementDays, 1);
    expect(progress.pendingPointAwards, 0);
    expect(progress.confirmedPoints, 10);
  });

  test('uses the server points_balance when the server supplies one', () async {
    await database
        .into(database.localProgressProjections)
        .insert(
          LocalProgressProjectionsCompanion.insert(
            userId: 'user-1',
            projectionType: 'points',
            payloadJson: jsonEncode({'points_balance': 25}),
            serverUpdatedAt: DateTime.utc(2026, 9, 7),
          ),
        );
    await database
        .into(database.localProgressProjections)
        .insert(
          LocalProgressProjectionsCompanion.insert(
            userId: 'user-1',
            projectionType: 'weekly_progress',
            payloadJson: jsonEncode({
              'week_start': '2026-09-07T00:00:00+03:00',
              'timezone': 'Asia/Riyadh',
              'goal_days': 3,
              'movement_days': 0,
            }),
            serverUpdatedAt: DateTime.utc(2026, 9, 7),
          ),
        );

    final progress = await _repository(
      database,
      now: DateTime.utc(2026, 9, 8),
    ).currentWeeklyGoal();

    expect(progress.isAuthoritative, isTrue);
    expect(progress.confirmedPoints, 25);
  });

  test(
    'layers an unresolved local completion over an authoritative week',
    () async {
      await _session(
        database,
        id: 'offline-session',
        completedAt: DateTime.utc(2026, 9, 7, 8),
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              payloadJson: jsonEncode({
                'week_start': '2026-09-06T21:00:00+00:00',
                'timezone': 'Asia/Riyadh',
                'goal_days': 3,
                'movement_days': 1,
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 7),
            ),
          );

      final progress = await _repository(
        database,
        now: DateTime.utc(2026, 9, 8),
      ).currentWeeklyGoal();

      expect(progress.movementDays, 2);
      expect(progress.pendingPointAwards, 1);
      expect(progress.isAuthoritative, isFalse);
    },
  );

  test(
    'unions same Monday from server movement_dates and offline session',
    () async {
      await _session(
        database,
        id: 'offline-monday',
        completedAt: DateTime.utc(2026, 9, 7, 8),
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              payloadJson: jsonEncode({
                'week_start': '2026-09-06T21:00:00Z',
                'timezone': 'Asia/Riyadh',
                'goal_days': 3,
                'movement_days': 1,
                'movement_dates': ['2026-09-07'],
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 7),
            ),
          );
      final progress = await _repository(
        database,
        now: DateTime.utc(2026, 9, 8),
      ).currentWeeklyGoal();
      expect(progress.movementDays, 1);
      expect(progress.pendingPointAwards, 1);
    },
  );

  test(
    'uses Monday boundaries and the session timezone preserved at completion',
    () async {
      // 2026-09-07 00:30 UTC is still Sunday in America/Los_Angeles.
      await _session(
        database,
        id: 'sunday-la',
        completedAt: DateTime.utc(2026, 9, 7, 0, 30),
        timezone: 'America/Los_Angeles',
      );
      await _session(
        database,
        id: 'monday-riyadh',
        completedAt: DateTime.utc(2026, 9, 7, 0, 30),
        timezone: 'Asia/Riyadh',
      );

      final progress = await _repository(
        database,
        now: DateTime.utc(2026, 9, 8),
      ).currentWeeklyGoal();

      expect(progress.weekStart, const MovementDate(2026, 9, 7));
      expect(progress.movementDays, 1);
      expect(progress.pendingPointAwards, 1);
    },
  );

  test(
    'uses IANA daylight-saving offsets rather than a fixed device offset',
    () async {
      // The US DST change makes 07:30 UTC March 9 become Monday in Los Angeles.
      await database
          .into(database.localProfiles)
          .insertOnConflictUpdate(
            LocalProfilesCompanion.insert(
              userId: 'user-1',
              preferredLocale: 'en',
              timezone: 'America/Los_Angeles',
              weeklyGoalDays: 3,
              localUpdatedAt: DateTime.utc(2026),
            ),
          );
      await _session(
        database,
        id: 'dst',
        completedAt: DateTime.utc(2026, 3, 9, 7, 30),
        timezone: 'America/Los_Angeles',
      );

      final progress = await _repository(
        database,
        now: DateTime.utc(2026, 3, 10),
      ).currentWeeklyGoal();
      expect(progress.weekStart, const MovementDate(2026, 3, 9));
      expect(progress.movementDays, 1);
    },
  );

  test('projects an offline streak from captured session timezones', () async {
    await _session(
      database,
      id: 'travel-day-one',
      completedAt: DateTime.utc(2026, 9, 7, 23),
      timezone: 'Pacific/Honolulu',
    );
    await _session(
      database,
      id: 'travel-day-two',
      completedAt: DateTime.utc(2026, 9, 8, 23),
      timezone: 'Pacific/Honolulu',
    );

    final streak = await _repository(
      database,
      now: DateTime.utc(2026, 9, 9, 12),
    ).currentStreak();

    expect(streak.currentDays, 2);
    expect(streak.longestDays, 2);
    expect(streak.isAuthoritative, isFalse);
  });

  test(
    'authoritative streak projection replaces a delayed local estimate',
    () async {
      await _session(
        database,
        id: 'pending-streak',
        completedAt: DateTime.utc(2026, 9, 7, 8),
      );
      await (database.update(
        database.localRoutineSessions,
      )..where((row) => row.id.equals('pending-streak'))).write(
        const LocalRoutineSessionsCompanion(syncState: Value(SyncState.synced)),
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'streak',
              payloadJson: jsonEncode({
                'current_streak_days': 4,
                'longest_streak_days': 6,
                'rule_version': 'streak_v1',
                'last_movement_date': '2026-09-07',
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 7, 9),
            ),
          );

      final streak = await _repository(
        database,
        now: DateTime.utc(2026, 9, 8),
      ).currentStreak();

      expect(streak.currentDays, 4);
      expect(streak.longestDays, 6);
      expect(streak.isAuthoritative, isTrue);
    },
  );

  test(
    'pending offline completion temporarily overrides a cached server streak',
    () async {
      await _session(
        database,
        id: 'prior-synced',
        completedAt: DateTime.utc(2026, 9, 7, 8),
      );
      await (database.update(
        database.localRoutineSessions,
      )..where((row) => row.id.equals('prior-synced'))).write(
        const LocalRoutineSessionsCompanion(syncState: Value(SyncState.synced)),
      );
      await _session(
        database,
        id: 'offline-next-day',
        completedAt: DateTime.utc(2026, 9, 8, 8),
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'streak',
              payloadJson: jsonEncode({
                'current_streak_days': 1,
                'longest_streak_days': 1,
                'rule_version': 'streak_v1',
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 7, 9),
            ),
          );

      final streak = await _repository(
        database,
        now: DateTime.utc(2026, 9, 8, 12),
      ).currentStreak();

      expect(streak.currentDays, 2);
      expect(streak.isAuthoritative, isFalse);
    },
  );

  test(
    'expires a cached active streak after a missed local day offline',
    () async {
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'streak',
              payloadJson: jsonEncode({
                'current_streak_days': 2,
                'longest_streak_days': 4,
                'last_movement_date': '2026-09-07',
                'rule_version': 'streak_v1',
              }),
              serverUpdatedAt: DateTime.utc(2026, 9, 7, 9),
            ),
          );

      final streak = await _repository(
        database,
        now: DateTime.utc(2026, 9, 9, 12),
      ).currentStreak();

      expect(streak.currentDays, 0);
      expect(streak.longestDays, 4);
      expect(streak.isAuthoritative, isFalse);
    },
  );
}

DriftGamificationRepository _repository(
  AppDatabase database, {
  required DateTime now,
}) => DriftGamificationRepository(
  database,
  activeUserId: 'user-1',
  clock: () => now,
);

Future<void> _seed(AppDatabase database) async {
  final now = DateTime.utc(2026, 1, 1);
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
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
}

Future<void> _session(
  AppDatabase database, {
  required String id,
  required DateTime completedAt,
  String timezone = 'Asia/Riyadh',
}) => database
    .into(database.localRoutineSessions)
    .insert(
      LocalRoutineSessionsCompanion.insert(
        id: id,
        userId: 'user-1',
        routineId: 'routine-1',
        routineVersion: 1,
        status: 'completed',
        startedAt: completedAt.subtract(const Duration(minutes: 1)),
        completedAt: Value(completedAt),
        completedTimezone: Value(timezone),
        targetDurationSeconds: 60,
        actualDurationSeconds: 60,
        totalSteps: 1,
        stepsCompleted: const Value(1),
        completionPolicyVersion: 'mvp_v1',
        source: 'recommendation',
        syncState: const Value(SyncState.pendingUpdate),
        localUpdatedAt: completedAt,
      ),
    );
