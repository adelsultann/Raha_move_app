import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_rpc_gateway.dart';

/// Production [SyncRpcGateway] backed by a live Supabase client.
///
/// The RPCs (`sync_push_user_data` / `sync_pull_user_data`) derive the caller
/// identity from the authenticated session; no caller id is sent as a
/// parameter. A [PostgrestException] is a server-side rejection (validation or
/// authorization) and is surfaced as [SyncRpcRejectedException]; network and
/// timeout errors propagate so the transport treats them as retryable.
final class SupabaseSyncRpcGateway implements SyncRpcGateway {
  SupabaseSyncRpcGateway(this._client);

  final SupabaseClient _client;

  @override
  bool get isConfigured => true;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<Map<String, dynamic>?> rpc(
    String function,
    Map<String, dynamic> args,
  ) async {
    try {
      final result = await _client.rpc(function, params: args);
      if (result == null) return null;
      return Map<String, dynamic>.from(result as Map);
    } on PostgrestException catch (e) {
      throw SyncRpcRejectedException(e.details?.toString() ?? e.message);
    }
  }
}

/// Resolves the live [SyncRpcGateway] for the current process.
///
/// When the Supabase SDK has been initialized this returns a
/// [SupabaseSyncRpcGateway] around its client; otherwise it returns
/// [NoopSyncRpcGateway] so the app remains fully offline-capable and tests run
/// without a configured backend. The initialization check is defensive:
/// `Supabase.instance` asserts when `Supabase.initialize` was never called.
SyncRpcGateway resolveLiveSyncRpcGateway() {
  final client = _liveSupabaseClient();
  if (client == null) return const NoopSyncRpcGateway();
  return SupabaseSyncRpcGateway(client);
}

SupabaseClient? _liveSupabaseClient() {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
