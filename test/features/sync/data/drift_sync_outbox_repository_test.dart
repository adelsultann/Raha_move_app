import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/sync/data/drift_sync_outbox_repository.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';

import '../support/sync_test_harness.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  late AppDatabase db;
  late DriftSyncOutboxRepository outbox;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedSyncCatalog(db, now);
    outbox = DriftSyncOutboxRepository(
      db,
      activeUserId: 'user-1',
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  test('markSynced removes the outbox item and marks the row synced', () async {
    await userData(db, now).saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );

    final operation = (await outbox.dueOperations()).single;
    await outbox.markSynced(operation);

    expect(await db.select(db.syncOutbox).get(), isEmpty);
    final row = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(row.syncState, SyncState.synced);
    expect(row.lastSyncError, isNull);
  });

  test('acknowledging by id never clobbers a re-enqueued operation', () async {
    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    final stale = (await outbox.dueOperations()).single;

    await repo.saveCheckIn(
      checkIn: checkIn(
        'check-in-1',
        now,
      ).copyWith(bodyState: const Value('tense')),
      bodyAreaKeys: const ['shoulders'],
    );
    final fresh = (await outbox.dueOperations()).single;
    expect(fresh.outboxId, isNot(stale.outboxId));

    await outbox.markSynced(stale);
    final pending = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(pending.syncState, SyncState.pendingUpdate);

    await outbox.markSynced(fresh);
    final synced = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(synced.syncState, SyncState.synced);
  });

  test(
    'markRetryableFailure records backoff and a recoverable failure',
    () async {
      await userData(db, now).saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );

      final operation = (await outbox.dueOperations()).single;
      final nextAttemptAt = now.add(const Duration(seconds: 2));
      await outbox.markRetryableFailure(
        operation,
        nextAttemptCount: 1,
        nextAttemptAt: nextAttemptAt,
      );

      final queued = await db.select(db.syncOutbox).getSingle();
      expect(queued.attemptCount, 1);
      expect(
        queued.nextAttemptAt.millisecondsSinceEpoch,
        nextAttemptAt.millisecondsSinceEpoch,
      );
      expect(queued.status, OutboxStatus.pending);

      final row = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(row.syncState, SyncState.failed);
      expect(row.lastSyncError, SyncDiagnosticCode.networkUnavailable);
    },
  );

  test(
    'markRejected parks the item (retained) and records the diagnostic',
    () async {
      await userData(db, now).saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );

      final operation = (await outbox.dueOperations()).single;
      await outbox.markRejected(
        operation,
        code: SyncDiagnostics.validationRejected,
      );

      // The rejected operation is retained, never deleted.
      final queued = await db.select(db.syncOutbox).getSingle();
      expect(queued.status, OutboxStatus.rejected);
      expect(await outbox.dueOperations(), isEmpty);

      final row = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(row.syncState, SyncState.failed);
      expect(row.lastSyncError, SyncDiagnosticCode.validationRejected);
    },
  );

  test('storeProjections overrides a stale local projection', () async {
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

    await outbox.storeProjections([
      SyncProjection(
        projectionType: 'points',
        payloadJson: '{"points":5}',
        serverUpdatedAt: now,
      ),
    ]);

    final projections = await db.select(db.localProgressProjections).get();
    expect(projections, hasLength(1));
    expect(projections.single.payloadJson, contains('"points":5'));
  });

  test(
    'session acknowledgement marks its steps synced only when all ops ack',
    () async {
      final repo = userData(db, now);
      await repo.saveSessionWithSteps(
        session: session('session-1', now),
        steps: [completedStep('session-1', now)],
      );

      final operations = await outbox.dueOperations();
      expect(operations.map((op) => op.kind).toList(), [
        'session_start',
        'session_step_upsert',
        'session_finalize',
      ]);

      // Acking the start alone leaves the session pending.
      await outbox.markSynced(operations.first);
      var sessionRow = await (db.select(
        db.localRoutineSessions,
      )..where((r) => r.id.equals('session-1'))).getSingle();
      expect(sessionRow.syncState, SyncState.pendingCreate);

      for (final operation in operations.skip(1)) {
        await outbox.markSynced(operation);
      }
      sessionRow = await (db.select(
        db.localRoutineSessions,
      )..where((r) => r.id.equals('session-1'))).getSingle();
      final stepRow = await (db.select(
        db.localSessionSteps,
      )..where((r) => r.sessionId.equals('session-1'))).getSingle();
      expect(sessionRow.syncState, SyncState.synced);
      expect(stepRow.syncState, SyncState.synced);
    },
  );

  test('retryFailedOperations re-enqueues parked operations', () async {
    await userData(db, now).saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );
    final operation = (await outbox.dueOperations()).single;
    await outbox.markRejected(operation, code: SyncDiagnostics.retryExhausted);

    final rebuilt = await outbox.retryFailedOperations();
    expect(rebuilt, 1);
    final due = await outbox.dueOperations();
    expect(due, hasLength(1));
    expect(due.single.operationId, operation.operationId, reason: 'stable id');
  });

  test('pull never overwrites a newer local pending saved routine', () async {
    await userData(
      db,
      now,
    ).saveSavedRoutine(savedRoutine: savedRoutine('routine-1', now));

    await outbox.applyPullChanges([
      SyncPullChange(
        cursor: 1,
        entityType: 'saved_routine',
        entityId: routineUuid,
        operation: 'delete',
        payloadJson: jsonEncode({
          'routine_id': routineUuid,
          'saved': false,
          'operation_at': now.toIso8601String(),
        }),
        occurredAt: now,
      ),
    ]);

    final row =
        await (db.select(db.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals('user-1') & r.routineId.equals('routine-1'),
            ))
            .getSingle();
    expect(row.deletedAt, isNull, reason: 'local pending write preserved');
    expect(row.syncState, SyncState.pendingCreate);
  });

  test(
    'pull applies a server tombstone when no local pending write exists',
    () async {
      await outbox.applyPullChanges([
        SyncPullChange(
          cursor: 1,
          entityType: 'saved_routine',
          entityId: routineUuid,
          operation: 'delete',
          payloadJson: jsonEncode({
            'routine_id': routineUuid,
            'saved': false,
            'operation_at': now.toIso8601String(),
          }),
          occurredAt: now,
        ),
      ]);

      final row =
          await (db.select(db.localSavedRoutines)..where(
                (r) =>
                    r.userId.equals('user-1') & r.routineId.equals('routine-1'),
              ))
              .getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.syncState, SyncState.synced);
    },
  );

  test('pull reconciles a server-authored check-in', () async {
    const checkInId = '11111111-2222-4333-8444-555555555555';
    await outbox.applyPullChanges([
      SyncPullChange(
        cursor: 1,
        entityType: 'check_in',
        entityId: checkInId,
        operation: 'upsert',
        payloadJson: jsonEncode({
          'id': checkInId,
          'body_state': 'stiff',
          'goal_id': goalUuid,
          'available_minutes': 5,
          'started_at': now.toIso8601String(),
        }),
        occurredAt: now,
      ),
    ]);

    final row = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals(checkInId))).getSingle();
    expect(row.goalKey, 'ease_stiffness');
    expect(row.bodyState, 'stiff');
    expect(row.syncState, SyncState.synced);
  });

  test(
    'pull does not overwrite a pending or rejected local check-in',
    () async {
      await userData(db, now).saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );
      final operation = (await outbox.dueOperations()).single;
      await outbox.markRejected(
        operation,
        code: SyncDiagnostics.validationRejected,
      );

      await outbox.applyPullChanges([
        SyncPullChange(
          cursor: 1,
          entityType: 'check_in',
          entityId: 'check-in-1',
          operation: 'upsert',
          payloadJson: jsonEncode({
            'id': 'check-in-1',
            'body_state': 'tired',
            'goal_id': goalUuid,
            'available_minutes': 5,
            'started_at': now.toIso8601String(),
          }),
          occurredAt: now,
        ),
      ]);

      final row = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(row.bodyState, 'stiff', reason: 'local rejected write preserved');
    },
  );

  test('pull reconciles a recommendation and maps its routine id', () async {
    await db.into(db.localCheckIns).insert(checkIn('check-in-x', now));
    await outbox.applyPullChanges([
      SyncPullChange(
        cursor: 1,
        entityType: 'recommendation',
        entityId: 'rec-x',
        operation: 'upsert',
        payloadJson: jsonEncode({
          'id': 'rec-x',
          'check_in_id': 'check-in-x',
          'routine_id': routineUuid,
          'engine_version': 'rules_v1',
          'rank': 1,
          'score': 10,
          'reason_codes': ['body_area_match'],
          'shown_at': now.toIso8601String(),
        }),
        occurredAt: now,
      ),
    ]);

    final row = await (db.select(
      db.localRecommendations,
    )..where((r) => r.id.equals('rec-x'))).getSingle();
    expect(row.routineId, 'routine-1');
    expect(row.rank, 0, reason: 'wire rank is 1-based, local is 0-based');
    expect(row.reasonCodesJson, '["body_area_match"]');
  });

  test(
    'pull applies a server session finalize without regressing to in_progress',
    () async {
      await db.into(db.localRoutineSessions).insert(session('session-x', now));
      await outbox.applyPullChanges([
        SyncPullChange(
          cursor: 2,
          entityType: 'session',
          entityId: 'session-x',
          operation: 'finalize',
          payloadJson: jsonEncode({'id': 'session-x', 'status': 'completed'}),
          occurredAt: now,
        ),
      ]);

      final row = await (db.select(
        db.localRoutineSessions,
      )..where((r) => r.id.equals('session-x'))).getSingle();
      expect(row.status, 'completed');
      expect(row.completedAt, isNotNull);
      expect(row.syncState, SyncState.synced);
    },
  );

  test(
    'pull reconciles a session step and maps its exercise snapshot',
    () async {
      await db.into(db.localRoutineSessions).insert(session('session-x', now));
      await outbox.applyPullChanges([
        SyncPullChange(
          cursor: 2,
          entityType: 'session_step',
          entityId: 'session-x',
          operation: 'upsert',
          payloadJson: jsonEncode({
            'session_id': 'session-x',
            'routine_step_id': 'step-1',
            'exercise_id_snapshot': exerciseUuid,
            'position_snapshot': 1,
            'status': 'completed',
            'target_duration_seconds': 60,
            'active_duration_seconds': 60,
          }),
          occurredAt: now,
        ),
      ]);

      final step = await (db.select(
        db.localSessionSteps,
      )..where((r) => r.sessionId.equals('session-x'))).getSingle();
      expect(step.status, 'completed');
      expect(step.exerciseIdSnapshot, 'exercise-1');
      expect(step.syncState, SyncState.synced);
    },
  );

  test(
    'pull reconciles feedback and resolves an uncomfortable exercise',
    () async {
      await db.into(db.localRoutineSessions).insert(session('session-x', now));
      await outbox.applyPullChanges([
        SyncPullChange(
          cursor: 2,
          entityType: 'feedback',
          entityId: 'session-x',
          operation: 'upsert',
          payloadJson: jsonEncode({
            'session_id': 'session-x',
            'rating': 'same',
            'uncomfortable_exercise_id': exerciseUuid,
            'created_at': now.toIso8601String(),
          }),
          occurredAt: now,
        ),
      ]);

      final feedback = await (db.select(
        db.localSessionFeedback,
      )..where((r) => r.sessionId.equals('session-x'))).getSingle();
      expect(feedback.rating, 'same');
      expect(feedback.uncomfortableExerciseId, 'exercise-1');
      expect(feedback.syncState, SyncState.synced);
    },
  );
}
