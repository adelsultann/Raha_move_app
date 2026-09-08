import '../../../core/database/app_database.dart';
import 'rpc_account_deletion_action.dart';

/// Prevents Supabase from restoring an old session while an accepted account
/// deletion still has local cleanup work. Any inability to inspect the durable
/// marker is fail-closed: no authenticated SDK initialization is permitted.
final class AccountDeletionStartupGuard {
  const AccountDeletionStartupGuard({
    required this.hasPendingCleanup,
    required this.clearPersistedSession,
  });

  final Future<bool> Function() hasPendingCleanup;
  final Future<void> Function() clearPersistedSession;

  /// Returns whether Supabase initialization is safe. Clearing a persisted
  /// session is best effort, but a failure still blocks initialization so it
  /// cannot restore or refresh the deleted account's credential.
  Future<bool> permitsSupabaseInitialization() async {
    try {
      if (!await hasPendingCleanup()) return true;
    } catch (_) {
      return false;
    }
    try {
      await clearPersistedSession();
    } catch (_) {
      // The recovery gate will retry the complete local cleanup after startup.
    }
    return false;
  }
}

/// Reads only the durable deletion marker. It intentionally does not restore
/// identity, run synchronization, or contact an SDK.
Future<bool> hasPendingAccountDeletionCleanup(AppDatabase database) async {
  final entries = await database.select(database.environmentEntries).get();
  return entries.any(
    (entry) => entry.key.startsWith(DriftAccountDeletionCleanup.markerPrefix),
  );
}
