import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/progress/data/drift_progress_repository.dart';
import 'package:raha_move/features/progress/domain/progress_summary.dart';
import 'package:raha_move/features/progress/application/progress_week_calculator.dart';

void main() {
  late AppDatabase database;
  late DriftProgressRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftProgressRepository(database, activeUserId: 'user-1');
    await _seed(database);
  });
  tearDown(() => database.close());

  test('counts multiple completed sessions on one local day once', () async {
    await _session(
      database,
      id: 'one',
      completedAt: DateTime.utc(2026, 9, 8, 8),
    );
    await _session(
      database,
      id: 'two',
      completedAt: DateTime.utc(2026, 9, 8, 20),
    );

    final summary = await _summary(repository);
    expect(summary.movementDays, 1);
    expect(summary.completedRoutines, 2);
    expect(summary.verifiedActiveMinutes, 10);
    expect(summary.bodyAreas.single.label, 'Neck');
  });

  test(
    'uses Monday local week boundaries, not UTC calendar boundaries',
    () async {
      // Sunday 21:30 UTC is Monday in Asia/Riyadh.
      await _session(
        database,
        id: 'monday-riyadh',
        completedAt: DateTime.utc(2026, 9, 6, 21, 30),
      );
      await _session(
        database,
        id: 'next-monday-riyadh',
        completedAt: DateTime.utc(2026, 9, 13, 21, 30),
      );

      final summary = await _summary(repository);
      expect(summary.completedRoutines, 1);
      expect(summary.recentHistory.single.sessionId, 'monday-riyadh');
    },
  );

  test(
    'keeps a completed day in its captured timezone after profile changes',
    () async {
      await _session(
        database,
        id: 'travel',
        completedAt: DateTime.utc(2026, 9, 6, 23),
        timezone: 'America/Los_Angeles',
      );
      await (database.update(database.localProfiles)
            ..where((p) => p.userId.equals('user-1')))
          .write(const LocalProfilesCompanion(timezone: Value('Asia/Riyadh')));

      final summary = await _summary(
        repository,
        const MovementDate(2026, 8, 31),
      );
      expect(summary.completedRoutines, 1);
    },
  );

  test('excludes skipped, abandoned, and in-progress sessions', () async {
    await _session(
      database,
      id: 'completed',
      completedAt: DateTime.utc(2026, 9, 8),
    );
    await _session(
      database,
      id: 'abandoned',
      status: 'abandoned',
      completedAt: DateTime.utc(2026, 9, 8),
    );
    await _session(database, id: 'in-progress', status: 'in_progress');

    final summary = await _summary(repository);
    expect(summary.completedRoutines, 1);
    expect(summary.verifiedActiveMinutes, 5);
  });

  test(
    'offline reconciliation changes one session instead of duplicating it',
    () async {
      await _session(
        database,
        id: 'offline-session',
        completedAt: DateTime.utc(2026, 9, 8),
        syncState: SyncState.pendingCreate,
      );
      var summary = await _summary(repository);
      expect(summary.completedRoutines, 1);
      expect(summary.hasProvisionalProgress, isTrue);

      await (database.update(
        database.localRoutineSessions,
      )..where((s) => s.id.equals('offline-session'))).write(
        const LocalRoutineSessionsCompanion(syncState: Value(SyncState.synced)),
      );
      summary = await _summary(repository);
      expect(summary.completedRoutines, 1);
      expect(summary.movementDays, 1);
      expect(summary.hasProvisionalProgress, isFalse);
    },
  );

  test(
    'weekly authority uses movement dates while detailed progress stays local',
    () async {
      await _session(
        database,
        id: 'accepted',
        completedAt: DateTime.utc(2026, 9, 8),
      );
      await _session(
        database,
        id: 'pending',
        completedAt: DateTime.utc(2026, 9, 8, 2),
        syncState: SyncState.pendingCreate,
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              serverUpdatedAt: DateTime.utc(2026, 9, 8),
              payloadJson: '{"rule_version":"weekly_movement_v1","week_start":"2026-09-06T21:00:00Z","week_end":"2026-09-13T21:00:00Z","timezone":"Asia/Riyadh","goal_days":3,"movement_days":1,"movement_dates":["2026-09-08"]}',
            ),
          );
      final summary = await _summary(repository);
      expect(summary.movementDays, 1);
      expect(summary.verifiedActiveSeconds, 600);
      expect(summary.completedRoutines, 2);
      expect(summary.hasProvisionalProgress, isTrue);
    },
  );

  test(
    'projection-only synchronization refreshes the summary stream',
    () async {
      await _session(
        database,
        id: 'local',
        completedAt: DateTime.utc(2026, 9, 8),
      );
      final summaries = repository
          .watchWeeklySummary(
            weekStart: const MovementDate(2026, 9, 7),
            locale: 'en',
          )
          .asBroadcastStream();
      expect((await summaries.first).weeklyGoalDays, 3);
      final refreshed = summaries.first;
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              serverUpdatedAt: DateTime.utc(2026, 9, 8),
              payloadJson: '{"rule_version":"weekly_movement_v1","week_start":"2026-09-06T21:00:00Z","week_end":"2026-09-13T21:00:00Z","timezone":"Asia/Riyadh","goal_days":4,"movement_days":1,"movement_dates":["2026-09-08"]}',
            ),
          );
      expect((await refreshed).weeklyGoalDays, 4);
    },
  );

  test(
    'omitted movement dates use local stable IDs without same-day double count',
    () async {
      await _session(
        database,
        id: 'synced',
        completedAt: DateTime.utc(2026, 9, 8),
      );
      await _session(
        database,
        id: 'pending',
        completedAt: DateTime.utc(2026, 9, 8),
        syncState: SyncState.pendingCreate,
      );
      await database
          .into(database.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              serverUpdatedAt: DateTime.utc(2026, 9, 8),
              payloadJson: '{"rule_version":"weekly_movement_v1","week_start":"2026-09-06T21:00:00Z","week_end":"2026-09-13T21:00:00Z","timezone":"Asia/Riyadh","goal_days":3,"movement_days":0}',
            ),
          );
      expect((await _summary(repository)).movementDays, 1);
    },
  );

  test('malformed, type-mismatched, or invalid-goal projections safely fall back locally', () async {
    await _session(
      database,
      id: 'local',
      completedAt: DateTime.utc(2026, 9, 8),
    );
    for (final payload in [
      '[]',
      '{"week_start":7,"timezone":false}',
      '{"week_start":"2026-09-06T21:00:00Z","timezone":"Asia/Riyadh","goal_days":9}',
    ]) {
      await database
          .into(database.localProgressProjections)
          .insertOnConflictUpdate(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'weekly_progress',
              serverUpdatedAt: DateTime.utc(2026, 9, 8),
              payloadJson: payload,
            ),
          );
      final summary = await _summary(repository);
      expect(summary.completedRoutines, 1);
      expect(summary.verifiedActiveSeconds, 300);
    }
  });

  test(
    'failed and pending-delete sessions are excluded, not called provisional',
    () async {
      await _session(
        database,
        id: 'failed',
        completedAt: DateTime.utc(2026, 9, 8),
        syncState: SyncState.failed,
      );
      await _session(
        database,
        id: 'deleting',
        completedAt: DateTime.utc(2026, 9, 8),
        syncState: SyncState.pendingDelete,
      );
      final summary = await _summary(repository);
      expect(summary.completedRoutines, 0);
      expect(summary.hasProvisionalProgress, isFalse);
    },
  );

  test('sums seconds before displaying whole active minutes', () async {
    await _session(
      database,
      id: 'ninety-1',
      completedAt: DateTime.utc(2026, 9, 8),
      activeSeconds: 90,
    );
    await _session(
      database,
      id: 'ninety-2',
      completedAt: DateTime.utc(2026, 9, 8, 2),
      activeSeconds: 90,
    );
    final summary = await _summary(repository);
    expect(summary.verifiedActiveSeconds, 180);
    expect(summary.verifiedActiveMinutes, 3);
  });

  test(
    'includes completed allowed skips but excludes abandoned zero-time skips',
    () async {
      await _session(
        database,
        id: 'allowed-skip',
        completedAt: DateTime.utc(2026, 9, 8),
        stepsSkipped: 1,
      );
      await _session(
        database,
        id: 'zero-time-skip',
        status: 'abandoned',
        completedAt: DateTime.utc(2026, 9, 8),
      );
      expect((await _summary(repository)).completedRoutines, 1);
    },
  );

  test(
    'current week changes at a timezone boundary with an injected clock',
    () {
      final calculator = ProgressWeekCalculator();
      final instant = DateTime.utc(2026, 9, 6, 22);
      expect(
        calculator.currentWeek(now: instant, timezone: 'America/Los_Angeles'),
        const MovementDate(2026, 8, 31),
      );
      expect(
        calculator.currentWeek(now: instant, timezone: 'Asia/Riyadh'),
        const MovementDate(2026, 9, 7),
      );
    },
  );
}

Future<ProgressSummary> _summary(
  DriftProgressRepository repository, [
  MovementDate week = const MovementDate(2026, 9, 7),
]) => repository.watchWeeklySummary(weekStart: week, locale: 'en').first;

Future<void> _seed(AppDatabase database) async {
  final now = DateTime.utc(2026, 9, 1);
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
          estimatedDurationSeconds: 300,
          version: 1,
          updatedAt: now,
        ),
      );
  await database
      .into(database.localRoutineTranslations)
      .insert(
        LocalRoutineTranslationsCompanion.insert(
          routineId: 'routine-1',
          locale: 'en',
          name: 'Desk reset',
          summary: 'Calm movement',
        ),
      );
  await database
      .into(database.localTaxonomies)
      .insert(LocalTaxonomiesCompanion.insert(key: 'neck', kind: 'body_area'));
  await database
      .into(database.localTaxonomyTranslations)
      .insert(
        LocalTaxonomyTranslationsCompanion.insert(
          taxonomyKey: 'neck',
          locale: 'en',
          label: 'Neck',
        ),
      );
  await database
      .into(database.localRoutineTaxonomies)
      .insert(
        LocalRoutineTaxonomiesCompanion.insert(
          routineId: 'routine-1',
          taxonomyKey: 'neck',
        ),
      );
}

Future<void> _session(
  AppDatabase database, {
  required String id,
  String status = 'completed',
  DateTime? completedAt,
  String timezone = 'Asia/Riyadh',
  SyncState syncState = SyncState.synced,
  int activeSeconds = 300,
  int stepsSkipped = 0,
}) {
  final now = completedAt ?? DateTime.utc(2026, 9, 8);
  return database
      .into(database.localRoutineSessions)
      .insert(
        LocalRoutineSessionsCompanion.insert(
          id: id,
          userId: 'user-1',
          routineId: 'routine-1',
          routineVersion: 1,
          status: status,
          startedAt: now.subtract(const Duration(minutes: 5)),
          completedAt: Value(completedAt),
          completedTimezone: Value(completedAt == null ? null : timezone),
          targetDurationSeconds: 300,
          actualDurationSeconds: status == 'completed' ? activeSeconds : 0,
          totalSteps: 5,
          stepsCompleted: Value(status == 'completed' ? 4 : 0),
          stepsSkipped: Value(stepsSkipped),
          completionPolicyVersion: 'mvp_v1',
          source: 'recommendation',
          localUpdatedAt: now,
          syncState: Value(syncState),
        ),
      );
}
