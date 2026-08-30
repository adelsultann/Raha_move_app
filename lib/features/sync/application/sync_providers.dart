import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_sync_outbox_repository.dart';
import '../data/supabase_sync_rpc_gateway.dart';
import '../data/supabase_sync_transport.dart';
import '../data/sync_rpc_gateway.dart';
import '../domain/sync_transport.dart';
import '../domain/user_data_sync_engine.dart';

part 'sync_providers.g.dart';

/// The currently authenticated user id, or null when signed out. Owned by the
/// authentication feature; it is declared here so the sync coordinator has one
/// app-owned, stable signal for "who may sync now". It derives from the auth
/// controller's active user id (null only while the controller is initializing)
/// and stays overridable for tests.
@Riverpod(keepAlive: true)
String? activeUserId(Ref ref) =>
    ref.watch(authControllerProvider).value?.activeUserId;

/// Injectable RPC gateway for user-data sync. Uses the live Supabase client
/// when it has been initialized, and otherwise falls back to the offline no-op
/// so the application compiles and runs without a backend.
@Riverpod(keepAlive: true)
SyncRpcGateway syncRpcGateway(Ref ref) => resolveLiveSyncRpcGateway();

/// Injectable boundary to the trusted user-data sync API. When the gateway is
/// unconfigured or the bound user is unauthenticated the transport reports
/// [SyncUnavailable] so the outbox is retained without consuming retry budget.
@riverpod
SyncTransport syncTransport(Ref ref, String activeUserId) {
  return SupabaseSyncTransport(
    ref.watch(syncRpcGatewayProvider),
    ownerUserId: activeUserId,
  );
}

/// The user-data sync engine for the active user. Bound to one user because
/// outbox acknowledgement, cursor, and projection writes are owner-scoped.
@riverpod
UserDataSyncEngine userDataSyncEngine(Ref ref, String activeUserId) {
  return UserDataSyncEngine(
    outbox: DriftSyncOutboxRepository(
      ref.watch(appDatabaseProvider),
      activeUserId: activeUserId,
      appVersion: ref.watch(appVersionProvider),
      operationIdGenerator: generateUuidV4,
    ),
    transport: ref.watch(syncTransportProvider(activeUserId)),
  );
}
