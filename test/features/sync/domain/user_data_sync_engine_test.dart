import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/sync/data/drift_sync_outbox_repository.dart';
import 'package:raha_move/features/sync/domain/backoff_policy.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';
import 'package:raha_move/features/sync/domain/user_data_sync_engine.dart';

import '../support/sync_test_harness.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  late AppDatabase db;
  late MutableClock clock;
  late DriftSyncOutboxRepository outbox;
  late FakeSyncTransport transport;

  const shortBackoff = BackoffPolicy(
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 4),
    maxAttempts: 3,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedSyncCatalog(db, now);
    clock = MutableClock(now);
    outbox = DriftSyncOutboxRepository(
      db,
      activeUserId: 'user-1',
      clock: clock.call,
    );
    transport = FakeSyncTransport();
  });

  tearDown(() => db.close());

  UserDataSyncEngine engine({BackoffPolicy backoff = shortBackoff}) =>
      UserDataSyncEngine(
        outbox: outbox,
        transport: transport,
        backoff: backoff,
        clock: clock.call,
      );

  Future<void> enqueueOfflineJourney({
    required LocalUserDataRepository repo,
    required String checkInId,
    required String recommendationId,
    required String sessionId,
  }) async {
    await repo.saveCheckIn(
      checkIn: checkIn(checkInId, now),
      bodyAreaKeys: const ['shoulders'],
    );
    await repo.saveRecommendation(
      recommendation: recommendation(recommendationId, checkInId, now),
    );
    await repo.saveSessionWithSteps(
      session: session(sessionId, now),
      steps: [completedStep(sessionId, now)],
    );
    await repo.saveFeedback(feedback: feedback(sessionId, now));
  }

  test(
    'pushes operations in check-in -> recommendation -> session -> feedback '
    'dependency order, with a terminal session split into start/steps/finalize',
    () async {
      final repo = userData(db, now);
      await enqueueOfflineJourney(
        repo: repo,
        checkInId: 'check-in-1',
        recommendationId: 'recommendation-1',
        sessionId: 'session-1',
      );
      await repo.saveSavedRoutine(savedRoutine: savedRoutine('routine-1', now));

      final result = await engine().synchronize();

      expect(transport.pushed.map((op) => op.kind).toList(), [
        'check_in_upsert',
        'recommendation_upsert',
        'session_start',
        'session_step_upsert',
        'session_finalize',
        'feedback_upsert',
        'saved_routine_set',
      ]);
      expect(result.succeeded, 7);
      expect(result.hasFailures, isFalse);
      expect(await outbox.dueOperations(), isEmpty);
    },
  );

  test(
    'persists a stable UUID operation id and reuses it across retries',
    () async {
      final repo = userData(db, now);
      await repo.saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );

      final row = await db.select(db.syncOutbox).getSingle();
      expect(
        row.operationId,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ),
        ),
      );

      var failFirst = true;
      transport = FakeSyncTransport(
        onPush: (op) async {
          if (failFirst) {
            failFirst = false;
            return const SyncRetryableFailure();
          }
          return const SyncAccepted();
        },
      );

      final first = await engine().synchronize();
      expect(first.retryableFailures, 1);

      final due = await outbox.dueOperations();
      expect(due, isEmpty, reason: 'failed item is not due until its backoff');
      final outboxRow = await db.select(db.syncOutbox).getSingle();
      expect(outboxRow.attemptCount, 1);

      clock.value = outboxRow.nextAttemptAt;
      final second = await engine().synchronize();
      expect(second.succeeded, 1);
      expect(await db.select(db.syncOutbox).get(), isEmpty);

      // The same stable operation id was pushed twice.
      expect(transport.pushed, hasLength(2));
      expect(transport.pushed.first.operationId, row.operationId);
      expect(transport.pushed.last.operationId, row.operationId);
      expect(
        transport.pushed.first.payloadJson,
        transport.pushed.last.payloadJson,
      );

      final synced = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(synced.syncState, SyncState.synced);
    },
  );

  test(
    'exhausts retries and parks the operation without deleting it',
    () async {
      final repo = userData(db, now);
      await repo.saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );
      transport = FakeSyncTransport(
        onPush: (op) async => const SyncRetryableFailure(),
      );

      var result = await engine().synchronize();
      expect(result.retryableFailures, 1);
      var row = await db.select(db.syncOutbox).getSingle();
      expect(row.attemptCount, 1);
      expect(row.status, OutboxStatus.pending);

      clock.value = now.add(const Duration(seconds: 1));
      result = await engine().synchronize();
      row = await db.select(db.syncOutbox).getSingle();
      expect(row.attemptCount, 2);

      clock.value = now.add(const Duration(seconds: 3));
      result = await engine().synchronize();
      expect(result.rejected, 1);

      // The exhausted operation is retained (parked), never deleted.
      row = await db.select(db.syncOutbox).getSingle();
      expect(row.status, OutboxStatus.rejected);
      expect(row.operationId, isNotEmpty);
      expect(await outbox.dueOperations(), isEmpty);

      final checkInRow = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(checkInRow.syncState, SyncState.failed);
      expect(checkInRow.lastSyncError, SyncDiagnosticCode.retryExhausted);
      expect(checkInRow.bodyState, 'stiff', reason: 'local data is preserved');
    },
  );

  test('caps the backoff delay at maxDelay across repeated failures', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    transport = FakeSyncTransport(
      onPush: (op) async => const SyncRetryableFailure(),
    );
    final generous = UserDataSyncEngine(
      outbox: outbox,
      transport: transport,
      backoff: const BackoffPolicy(
        baseDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 4),
        maxAttempts: 100,
      ),
      clock: clock.call,
    );

    DateTime next = now;
    const expectedDelays = [1, 2, 4, 4];
    for (final expectedDelay in expectedDelays) {
      await generous.synchronize();
      final row = await db.select(db.syncOutbox).getSingle();
      final nextAttempt = row.nextAttemptAt;
      expect(nextAttempt.difference(next).inSeconds, expectedDelay);
      next = nextAttempt;
      clock.value = nextAttempt;
    }
  });

  test('network failure leaves normal local use unaffected', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    transport = FakeSyncTransport(
      onPush: (op) async => const SyncRetryableFailure(),
    );

    final result = await engine().synchronize();
    expect(result.hasFailures, isTrue);

    final checkInRow = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(checkInRow.syncState, SyncState.failed);
    expect(checkInRow.lastSyncError, SyncDiagnosticCode.networkUnavailable);
    expect(checkInRow.bodyState, 'stiff');
    expect(await outbox.dueOperations(), isEmpty);

    // A new write still works locally and enqueues independently.
    await repo.saveSavedRoutine(savedRoutine: savedRoutine('routine-1', now));
    final due = await outbox.dueOperations();
    expect(due.map((op) => op.kind), ['saved_routine_set']);
  });

  test('unexpected transport exceptions are treated as retryable', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );

    final result = await UserDataSyncEngine(
      outbox: outbox,
      transport: const ThrowingSyncTransport(),
      backoff: shortBackoff,
      clock: clock.call,
    ).synchronize();

    expect(result.retryableFailures, 1);
    final row = await db.select(db.syncOutbox).getSingle();
    expect(row.attemptCount, 1);
  });

  test('a completed session cannot regress after synchronization', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    await repo.saveRecommendation(
      recommendation: recommendation('recommendation-1', 'check-in-1', now),
    );
    await repo.saveSessionWithSteps(
      session: session('session-1', now),
      steps: [completedStep('session-1', now)],
    );

    await engine().synchronize();

    final persisted = await (db.select(
      db.localRoutineSessions,
    )..where((r) => r.id.equals('session-1'))).getSingle();
    expect(persisted.status, 'completed');
    expect(persisted.syncState, SyncState.synced);

    final steps = await (db.select(
      db.localSessionSteps,
    )..where((r) => r.sessionId.equals('session-1'))).get();
    expect(steps.single.syncState, SyncState.synced);

    await engine().synchronize();
    final again = await (db.select(
      db.localRoutineSessions,
    )..where((r) => r.id.equals('session-1'))).getSingle();
    expect(again.status, 'completed');
  });

  test(
    'offline completion syncs feedback and exactly one reward projection',
    () async {
      final repo = userData(db, now);
      await enqueueOfflineJourney(
        repo: repo,
        checkInId: 'check-in-1',
        recommendationId: 'recommendation-1',
        sessionId: 'session-1',
      );

      final reward = SyncProjection(
        projectionType: 'points',
        payloadJson: '{"points":5}',
        serverUpdatedAt: now,
      );
      transport = FakeSyncTransport(
        onPush: (op) async => op.kind == 'session_finalize'
            ? SyncAccepted(projections: [reward], cursor: 100)
            : const SyncAccepted(),
      );

      await db
          .into(db.localProgressProjections)
          .insert(
            LocalProgressProjectionsCompanion.insert(
              userId: 'user-1',
              projectionType: 'points',
              payloadJson: '{"points":0}',
              serverUpdatedAt: now,
            ),
          );

      final result = await engine().synchronize();

      expect(transport.pushed.map((op) => op.kind).toList(), [
        'check_in_upsert',
        'recommendation_upsert',
        'session_start',
        'session_step_upsert',
        'session_finalize',
        'feedback_upsert',
      ]);
      expect(result.projections, hasLength(1));
      expect(await outbox.pullCursor(), 100);

      final projections = await db.select(db.localProgressProjections).get();
      expect(projections, hasLength(1));
      expect(projections.single.projectionType, 'points');
      expect(projections.single.payloadJson, contains('"points":5'));

      // A repeat pass does not duplicate the reward or any operation.
      await engine().synchronize();
      expect(await db.select(db.localProgressProjections).get(), hasLength(1));
      expect(transport.pushed, hasLength(6));
    },
  );

  test(
    'an unavailable transport retains the outbox without consuming budget',
    () async {
      final repo = userData(db, now);
      await repo.saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );

      final result = await UserDataSyncEngine(
        outbox: outbox,
        transport: const UnavailableSyncTransport(),
        backoff: shortBackoff,
        clock: clock.call,
      ).synchronize();

      expect(result.skipped, 1);
      expect(result.hasFailures, isFalse);

      final row = await db.select(db.syncOutbox).getSingle();
      expect(row.status, OutboxStatus.pending);
      expect(row.attemptCount, 0, reason: 'no retry budget was consumed');
      expect(await outbox.dueOperations(), hasLength(1));
    },
  );

  test('pull applies the cursor and authoritative projections', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );

    transport = FakeSyncTransport(
      onPull: (afterCursor) async => SyncPullSuccess(
        changes: const [],
        cursor: 42,
        projections: [
          SyncProjection(
            projectionType: 'points',
            payloadJson: '{"points":5}',
            serverUpdatedAt: now,
          ),
        ],
      ),
    );

    final result = await engine().synchronize();
    expect(result.pulledChanges, 0);
    expect(await outbox.pullCursor(), 42);
    final projections = await db.select(db.localProgressProjections).get();
    expect(projections.single.projectionType, 'points');
  });

  test('retry() re-enqueues a parked operation and can then succeed', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    transport = FakeSyncTransport(
      onPush: (op) async => const SyncRetryableFailure(),
    );

    // Exhaust the short budget (3 attempts) to park the operation.
    for (var i = 0; i < 3; i++) {
      await engine().synchronize();
      final row = await db.select(db.syncOutbox).getSingle();
      clock.value = row.nextAttemptAt;
    }
    expect(
      (await db.select(db.syncOutbox).getSingle()).status,
      OutboxStatus.rejected,
    );

    // The network recovers; an explicit retry re-enqueues and succeeds.
    transport = FakeSyncTransport();
    final result = await engine().retry();
    expect(result.succeeded, 1);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });
}
