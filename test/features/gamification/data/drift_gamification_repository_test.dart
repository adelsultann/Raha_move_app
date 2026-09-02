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

  test('unions same Monday from server movement_dates and offline session', () async {
    await _session(
      database,
      id: 'offline-monday',
      completedAt: DateTime.utc(2026, 9, 7, 8),
    );
    await database.into(database.localProgressProjections).insert(
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
  });

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
