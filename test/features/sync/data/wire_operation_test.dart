import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../support/sync_test_harness.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);
  final isoNow = now.toIso8601String();

  late AppDatabase db;
  late WireOperationBuilder builder;
  late LocalUserDataRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedSyncCatalog(db, now);
    builder = WireOperationBuilder(
      db,
      activeUserId: 'user-1',
      appVersion: '1.0.0',
    );
    repo = userData(db, now);
  });

  tearDown(() => db.close());

  test(
    'check-in wire payload is snake_case and resolves taxonomy keys to UUIDs',
    () async {
      await repo.saveCheckIn(
        checkIn: checkIn(
          'check-in-1',
          now,
        ).copyWith(completedAt: const Value(null)),
        bodyAreaKeys: const ['shoulders'],
      );
      final envelopes = await builder.buildFor('check_in', 'check-in-1');
      expect(envelopes, hasLength(1));
      expect(envelopes.single.kind, 'check_in_upsert');
      expect(envelopes.single.payload, {
        'id': 'check-in-1',
        'body_state': 'stiff',
        'goal_id': goalUuid,
        'available_minutes': 5,
        'started_at': isoNow,
        'body_area_ids': [shouldersUuid],
      });
    },
  );

  test(
    'session flushes as start + ordered steps + finalize with resolved UUIDs',
    () async {
      await repo.saveSessionWithSteps(
        session: session('session-1', now),
        steps: [completedStep('session-1', now)],
      );

      final envelopes = await builder.buildFor('routine_session', 'session-1');
      expect(envelopes.map((e) => e.kind).toList(), [
        'session_start',
        'session_step_upsert',
        'session_finalize',
      ]);

      expect(envelopes[0].payload, {
        'id': 'session-1',
        'routine_id': routineUuid,
        'routine_version': 1,
        'source': 'recommendation',
        'app_version': '1.0.0',
      });

      expect(envelopes[1].sequence, 1);
      expect(envelopes[1].payload, {
        'session_id': 'session-1',
        'routine_step_id': 'step-1',
        'exercise_id_snapshot': exerciseUuid,
        'position_snapshot': 1,
        'status': 'completed',
        'target_duration_seconds': 60,
        'active_duration_seconds': 60,
        'skip_requested': false,
        'started_at': isoNow,
        'finished_at': isoNow,
      });

      expect(envelopes[2].payload, {
        'session_id': 'session-1',
        'completion_policy_version': 'raha_001_v1',
        'completed_timezone': 'Asia/Riyadh',
      });
    },
  );

  test('saved routine sends routine_id, saved, and operation_at from local update time', () async {
    await repo.saveSavedRoutine(savedRoutine: savedRoutine('routine-1', now));
    final envelopes = await builder.buildFor('saved_routine', 'routine-1');
    expect(envelopes, hasLength(1));
    expect(envelopes.single.kind, 'saved_routine_set');
    expect(envelopes.single.payload, {
      'routine_id': routineUuid,
      'saved': true,
      'operation_at': isoNow,
    });
  });

  test(
    'feedback resolves an uncomfortable exercise id and carries created_at',
    () async {
      await repo.saveSessionWithSteps(
        session: session('session-1', now),
        steps: [completedStep('session-1', now)],
      );
      await repo.saveFeedback(
        feedback: feedback(
          'session-1',
          now,
        ).copyWith(uncomfortableExerciseId: const Value('exercise-1')),
      );
      final envelopes = await builder.buildFor('session_feedback', 'session-1');
      expect(envelopes.single.kind, 'feedback_upsert');
      expect(envelopes.single.payload, {
        'session_id': 'session-1',
        'rating': 'little_better',
        'uncomfortable_exercise_id': exerciseUuid,
        'created_at': isoNow,
      });
    },
  );

  test(
    'a local id that is already a UUID is used directly, never resolved',
    () async {
      // The session id is a client-generated UUID; it passes through untouched.
      const sessionUuid = '11111111-2222-4333-8444-555555555555';
      await repo.saveSessionWithSteps(
        session: session(sessionUuid, now),
        steps: [completedStep(sessionUuid, now)],
      );
      final envelopes = await builder.buildFor('routine_session', sessionUuid);
      expect(envelopes[0].payload['id'], sessionUuid);
      expect(envelopes[1].payload['session_id'], sessionUuid);
      expect(envelopes[2].payload['session_id'], sessionUuid);
    },
  );

  test(
    'recommendation maps local 0-based rank to the backend 1-based rank',
    () async {
      await repo.saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );
      await repo.saveRecommendation(
        recommendation: recommendation(
          'recommendation-1',
          'check-in-1',
          now,
        ).copyWith(reasonCodesJson: const Value('["body_area_match"]')),
      );
      final envelopes = await builder.buildFor(
        'recommendation',
        'recommendation-1',
      );
      expect(envelopes.single.kind, 'recommendation_upsert');
      expect(envelopes.single.payload['rank'], 1);
      expect(envelopes.single.payload['routine_id'], routineUuid);
      expect(envelopes.single.payload['reason_codes'], ['body_area_match']);
    },
  );

  test(
    'an unresolvable remote id parks the write without deleting it',
    () async {
      // Remove the goal mapping so the check-in payload becomes impossible.
      await (db.delete(db.localIdMappings)..where(
            (r) =>
                r.kind.equals(RemoteIdMappingKind.taxonomy) &
                r.localId.equals('ease_stiffness'),
          ))
          .go();

      await repo.saveCheckIn(
        checkIn: checkIn('check-in-1', now),
        bodyAreaKeys: const ['shoulders'],
      );

      final outbox = await db.select(db.syncOutbox).getSingle();
      expect(outbox.status, OutboxStatus.rejected);
      expect(outbox.operationId, isNotEmpty);

      final row = await (db.select(
        db.localCheckIns,
      )..where((r) => r.id.equals('check-in-1'))).getSingle();
      expect(row.syncState, SyncState.failed);
      expect(row.lastSyncError, SyncDiagnosticCode.unmappedId);
      expect(row.bodyState, 'stiff', reason: 'local data is preserved');

      // Restoring the mapping and retrying re-enqueues the operation.
      final store = LocalIdMappingStore(db);
      await store.store(
        kind: RemoteIdMappingKind.taxonomy,
        localId: 'ease_stiffness',
        remoteId: goalUuid,
      );
      final rebuilt = await repo.rebuildOutboxOperation(
        'check_in',
        'check-in-1',
      );
      expect(rebuilt, isTrue);
      final pending = await repo.dueOutbox();
      expect(pending, hasLength(1));
      expect(pending.single.kind, 'check_in_upsert');
      expect(jsonDecode(pending.single.payloadJson)['goal_id'], goalUuid);
    },
  );
}
