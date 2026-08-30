/// Application-owned, injectable boundary to the authenticated Supabase RPCs
/// used by user-data sync. Keeps `supabase_flutter` out of the sync domain and
/// makes the transport trivially fakeable in tests.
abstract interface class SyncRpcGateway {
  /// Whether a Supabase project is configured (URL + anon key present).
  bool get isConfigured;

  /// The authenticated user id from the current live session, or null when no
  /// user is signed in.
  String? get currentUserId;

  /// Invokes an authenticated RPC and returns its decoded JSON body.
  ///
  /// Throws [SyncRpcRejectedException] for a permanent server rejection, and
  /// rethrows network/timeout errors for the transport to treat as retryable.
  Future<Map<String, dynamic>?> rpc(String function, Map<String, dynamic> args);
}

/// A permanent server rejection of an RPC (validation or authorization).
final class SyncRpcRejectedException implements Exception {
  const SyncRpcRejectedException(this.message);

  final String message;

  @override
  String toString() => 'SyncRpcRejectedException($message)';
}

/// The default offline gateway used while no Supabase project is configured.
/// Every push/pull is reported as unavailable so the engine retains the outbox
/// without consuming retry budget.
final class NoopSyncRpcGateway implements SyncRpcGateway {
  const NoopSyncRpcGateway();

  @override
  bool get isConfigured => false;

  @override
  String? get currentUserId => null;

  @override
  Future<Map<String, dynamic>?> rpc(
    String function,
    Map<String, dynamic> args,
  ) async {
    throw const SyncRpcRejectedException('sync is not configured');
  }
}
