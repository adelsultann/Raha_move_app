import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/sync/data/supabase_sync_transport.dart';
import 'package:raha_move/features/sync/data/sync_rpc_gateway.dart';
import 'package:raha_move/features/sync/domain/sync_operation.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';

class FakeSyncRpcGateway implements SyncRpcGateway {
  FakeSyncRpcGateway({this.configured = true, this.userId, this.onRpc});

  bool configured;
  String? userId;
  Future<Map<String, dynamic>?> Function(String fn, Map<String, dynamic> args)?
  onRpc;
  final List<({String fn, Map<String, dynamic> args})> calls = [];

  @override
  bool get isConfigured => configured;

  @override
  String? get currentUserId => userId;

  @override
  Future<Map<String, dynamic>?> rpc(
    String function,
    Map<String, dynamic> args,
  ) async {
    calls.add((fn: function, args: args));
    final handler = onRpc;
    if (handler != null) return handler(function, args);
    return const {};
  }
}

SyncOperation operation({
  String operationId = '11111111-2222-4333-8444-555555555555',
}) {
  return SyncOperation(
    outboxId: 1,
    operationId: operationId,
    kind: 'check_in_upsert',
    entityType: 'check_in',
    entityId: 'check-in-1',
    sequence: 0,
    payloadJson: '{"id":"check-in-1","body_state":"stiff"}',
    attemptCount: 0,
    createdAt: DateTime.utc(2026, 8, 30),
  );
}

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  test('an unconfigured transport reports push unavailable', () async {
    final transport = SupabaseSyncTransport(
      const NoopSyncRpcGateway(),
      ownerUserId: 'user-1',
      clock: () => now,
    );
    expect(await transport.push(operation()), isA<SyncUnavailable>());
    expect(await transport.pull(afterCursor: 0), isA<SyncPullUnavailable>());
  });

  test(
    'an authenticated different user reports unavailable (account switch)',
    () async {
      final gateway = FakeSyncRpcGateway(userId: 'user-2');
      final transport = SupabaseSyncTransport(
        gateway,
        ownerUserId: 'user-1',
        clock: () => now,
      );
      expect(await transport.push(operation()), isA<SyncUnavailable>());
      expect(gateway.calls, isEmpty);
    },
  );

  test(
    'logout (null session) reports unavailable without calling the backend',
    () async {
      final gateway = FakeSyncRpcGateway(userId: null);
      final transport = SupabaseSyncTransport(
        gateway,
        ownerUserId: 'user-1',
        clock: () => now,
      );
      expect(await transport.push(operation()), isA<SyncUnavailable>());
      expect(gateway.calls, isEmpty);
    },
  );

  test(
    'push sends the wire envelope and parses cursor and projections',
    () async {
      final gateway = FakeSyncRpcGateway(
        userId: 'user-1',
        onRpc: (fn, args) async => {
          'operations': [
            {
              'operation_id': '11111111-2222-4333-8444-555555555555',
              'status': 'applied',
            },
          ],
          'cursor': 42,
          'projections': {
            'points': [
              {'id': 'p1', 'points': 5, 'created_at': '2026-08-30T10:00:00Z'},
            ],
            'streak': null,
          },
        },
      );
      final transport = SupabaseSyncTransport(
        gateway,
        ownerUserId: 'user-1',
        clock: () => now,
      );

      final response = await transport.push(operation());

      expect(gateway.calls.single.fn, 'sync_push_user_data');
      final operations = gateway.calls.single.args['p_operations'] as List;
      expect(operations.single, {
        'operation_id': '11111111-2222-4333-8444-555555555555',
        'kind': 'check_in_upsert',
        'payload': {'id': 'check-in-1', 'body_state': 'stiff'},
      });

      final accepted = response as SyncAccepted;
      expect(accepted.cursor, 42);
      expect(accepted.projections, hasLength(1));
      expect(accepted.projections.single.projectionType, 'points');
      expect(accepted.projections.single.payloadJson, contains('"points":5'));
    },
  );

  test('a server validation rejection is surfaced as rejected', () async {
    final gateway = FakeSyncRpcGateway(
      userId: 'user-1',
      onRpc: (fn, args) async =>
          throw const SyncRpcRejectedException('operation_id must be a UUID'),
    );
    final transport = SupabaseSyncTransport(
      gateway,
      ownerUserId: 'user-1',
      clock: () => now,
    );
    expect(await transport.push(operation()), isA<SyncRejected>());
  });

  test('a network/unknown error is surfaced as retryable', () async {
    final gateway = FakeSyncRpcGateway(
      userId: 'user-1',
      onRpc: (fn, args) async => throw StateError('connection refused'),
    );
    final transport = SupabaseSyncTransport(
      gateway,
      ownerUserId: 'user-1',
      clock: () => now,
    );
    expect(await transport.push(operation()), isA<SyncRetryableFailure>());
  });

  test('pull parses changes, cursor, and projections', () async {
    final gateway = FakeSyncRpcGateway(
      userId: 'user-1',
      onRpc: (fn, args) async {
        expect(args['p_after_cursor'], 7);
        return {
          'changes': [
            {
              'cursor': 8,
              'entity_type': 'saved_routine',
              'entity_id': '00000000-0000-4000-8000-000000000101',
              'operation': 'delete',
              'payload': {
                'routine_id': '00000000-0000-4000-8000-000000000101',
                'saved': false,
                'operation_at': '2026-08-30T10:01:00Z',
              },
              'occurred_at': '2026-08-30T10:01:00Z',
            },
          ],
          'cursor': 8,
          'projections': {'points': <dynamic>[]},
        };
      },
    );
    final transport = SupabaseSyncTransport(
      gateway,
      ownerUserId: 'user-1',
      clock: () => now,
    );

    final response = await transport.pull(afterCursor: 7) as SyncPullSuccess;

    expect(response.cursor, 8);
    expect(response.changes, hasLength(1));
    expect(response.changes.single.entityType, 'saved_routine');
    expect(response.changes.single.operation, 'delete');
    expect(jsonDecode(response.changes.single.payloadJson)['saved'], isFalse);
    expect(response.projections.single.projectionType, 'points');
  });
}
