import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';
import 'package:raha_move/features/sync/application/user_data_sync_coordinator.dart';
import 'package:raha_move/features/sync/data/drift_sync_outbox_repository.dart';
import 'package:raha_move/features/sync/data/sync_rpc_gateway.dart';
import 'package:raha_move/features/sync/domain/user_data_sync_engine.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';

import '../support/sync_test_harness.dart';

class FakeSyncRpcGateway implements SyncRpcGateway {
  FakeSyncRpcGateway({this.currentUserId});

  @override
  bool get isConfigured => true;

  @override
  String? currentUserId;

  int rpcCalls = 0;

  @override
  Future<Map<String, dynamic>?> rpc(
    String function,
    Map<String, dynamic> args,
  ) async {
    rpcCalls++;
    return {
      'operations': <dynamic>[],
      'cursor': 0,
      'projections': <String, dynamic>{},
    };
  }
}

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  late AppDatabase db;
  late FakeSyncTransport transport;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedSyncCatalog(db, now);
    transport = FakeSyncTransport();
  });

  tearDown(() => db.close());

  ProviderContainer container({
    String? activeUserId,
    required FakeSyncRpcGateway gateway,
    InMemoryAnalyticsService? analytics,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appVersionProvider.overrideWithValue('1.0.0'),
        syncRpcGatewayProvider.overrideWithValue(gateway),
        activeUserIdProvider.overrideWithValue(activeUserId),
        if (analytics != null)
          analyticsServiceProvider.overrideWithValue(analytics),
        userDataSyncEngineProvider.overrideWith((ref, userId) {
          return UserDataSyncEngine(
            outbox: DriftSyncOutboxRepository(
              db,
              activeUserId: userId,
              clock: () => now,
            ),
            transport: transport,
            clock: () => now,
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('does not sync when no active user is signed in', () async {
    final gateway = FakeSyncRpcGateway(currentUserId: null);
    final c = container(activeUserId: null, gateway: gateway);

    expect(c.read(activeUserSyncCoordinatorProvider.notifier).canSync, isFalse);
    expect(
      await c.read(activeUserSyncCoordinatorProvider.notifier).synchronizeNow(),
      isNull,
    );
    expect(transport.pushed, isEmpty);
    expect(
      c.read(activeUserSyncCoordinatorProvider).phase,
      SyncCoordinatorPhase.unavailable,
    );
  });

  test('does not sync after logout or account switch', () async {
    final gateway = FakeSyncRpcGateway(currentUserId: 'user-2');
    final c = container(activeUserId: 'user-1', gateway: gateway);

    expect(c.read(activeUserSyncCoordinatorProvider.notifier).canSync, isFalse);
    expect(
      await c.read(activeUserSyncCoordinatorProvider.notifier).synchronizeNow(),
      isNull,
    );
    expect(transport.pushed, isEmpty);
    expect(
      c.read(activeUserSyncCoordinatorProvider).phase,
      SyncCoordinatorPhase.unavailable,
    );
  });

  test('synchronizes the active user once the session matches', () async {
    final gateway = FakeSyncRpcGateway(currentUserId: 'user-1');
    final c = container(activeUserId: 'user-1', gateway: gateway);

    expect(c.read(activeUserSyncCoordinatorProvider.notifier).canSync, isTrue);

    await userData(db, now).saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );

    final result = await c
        .read(activeUserSyncCoordinatorProvider.notifier)
        .synchronizeNow();
    expect(result, isNotNull);
    expect(transport.pushed, hasLength(1));
    expect(transport.pushed.single.kind, 'check_in_upsert');

    final row = await (db.select(
      db.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(row.syncState, SyncState.synced);
    expect(
      c.read(activeUserSyncCoordinatorProvider).phase,
      SyncCoordinatorPhase.synced,
    );
  });

  test('retry() re-enqueues parked operations and syncs', () async {
    final gateway = FakeSyncRpcGateway(currentUserId: 'user-1');
    final c = container(activeUserId: 'user-1', gateway: gateway);

    final repo = userData(db, now);
    await repo.saveCheckIn(
      checkIn: checkIn('check-in-1', now),
      bodyAreaKeys: const ['shoulders'],
    );

    final engine = c.read(userDataSyncEngineProvider('user-1'));
    final operation = (await engine.outbox.dueOperations()).single;
    await engine.outbox.markRejected(operation, code: 'retry_exhausted');

    final result = await c
        .read(activeUserSyncCoordinatorProvider.notifier)
        .retry();
    expect(result, isNotNull);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });

  test(
    'emits a consented event only after sync stores a points projection',
    () async {
      final analytics = InMemoryAnalyticsService(enabled: true);
      transport = FakeSyncTransport(
        onPull: (cursor) async => SyncPullSuccess(
          changes: const [],
          cursor: cursor + 1,
          projections: [
            SyncProjection(
              projectionType: 'points',
              payloadJson: '[{"id":"server-ledger-id","points":10,"rule_version":"points_completion_v1","source_type":"session","source_id":"private-session-id"}]',
              serverUpdatedAt: now,
            ),
          ],
        ),
      );
      final c = container(
        activeUserId: 'user-1',
        gateway: FakeSyncRpcGateway(currentUserId: 'user-1'),
        analytics: analytics,
      );

      await c.read(activeUserSyncCoordinatorProvider.notifier).synchronizeNow();

      expect(analytics.recordedEvents, hasLength(1));
      expect(
        analytics.recordedEvents.single.name,
        AnalyticsEventName.pointsAwarded,
      );
      expect(
        analytics.recordedEvents.single.properties.keys,
        unorderedEquals(['rule_version', 'point_amount', 'source_type']),
      );
    },
  );
}
