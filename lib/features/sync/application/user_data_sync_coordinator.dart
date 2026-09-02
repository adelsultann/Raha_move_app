import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/user_data_sync_engine.dart';
import 'sync_providers.dart';

part 'user_data_sync_coordinator.g.dart';

/// Lifecycle phase of the app-owned sync coordinator, exposed for recoverable
/// retry UI and diagnostics.
enum SyncCoordinatorPhase { idle, syncing, synced, failed, unavailable }

/// Coordinator state: the current phase and, after a pass, the last result.
final class SyncCoordinatorState {
  const SyncCoordinatorState({required this.phase, this.result});

  final SyncCoordinatorPhase phase;
  final SyncResult? result;

  static const idle = SyncCoordinatorState(phase: SyncCoordinatorPhase.idle);
}

/// App-owned, active-user sync trigger.
///
/// This is the single entry point callers use to run user-data synchronization
/// for the currently authenticated user. It is safe to call from authenticated
/// startup, connectivity recovery, and an explicit manual retry, because it
/// guards logout and account switch: when no user is signed in, or when the
/// live Supabase session no longer matches the active user, it returns `null`
/// without touching the backend or the outbox.
@Riverpod(keepAlive: true)
class ActiveUserSyncCoordinator extends _$ActiveUserSyncCoordinator {
  @override
  SyncCoordinatorState build() => SyncCoordinatorState.idle;

  /// Whether the coordinator currently has an authenticated active user whose
  /// live session matches the sync owner.
  bool get canSync {
    final userId = ref.read(activeUserIdProvider);
    if (userId == null) return false;
    return ref.read(syncRpcGatewayProvider).currentUserId == userId;
  }

  /// Runs one sync pass for the active user. Returns `null` when there is no
  /// active user or the live session has changed (logout/account switch).
  Future<SyncResult?> synchronizeNow() =>
      _run((engine) => engine.synchronize());

  /// Explicit, recoverable retry: re-enqueues parked operations and then runs a
  /// pass. Returns `null` when there is no active user or the session changed.
  Future<SyncResult?> retry() => _run((engine) => engine.retry());

  Future<SyncResult?> _run(
    Future<SyncResult> Function(UserDataSyncEngine engine) action,
  ) async {
    final userId = ref.read(activeUserIdProvider);
    if (userId == null) {
      state = const SyncCoordinatorState(
        phase: SyncCoordinatorPhase.unavailable,
      );
      return null;
    }
    // Logout / account-switch guard: never sync on behalf of a stale owner.
    if (ref.read(syncRpcGatewayProvider).currentUserId != userId) {
      state = const SyncCoordinatorState(
        phase: SyncCoordinatorPhase.unavailable,
      );
      return null;
    }

    state = const SyncCoordinatorState(phase: SyncCoordinatorPhase.syncing);
    final result = await action(ref.read(userDataSyncEngineProvider(userId)));
    // The engine stores returned projections before it returns. Run the
    // consent-gated delivery pass afterwards so no client-created or merely
    // provisional point estimate can produce analytics. A tracking failure is
    // isolated from sync; the missing receipt leaves it retryable next pass.
    try {
      await ref
          .read(pointsAwardAnalyticsGateProvider(userId))
          .emitPendingAwards();
    } catch (_) {
      // Analytics is optional and must not turn an otherwise successful sync
      // into a user-visible failure.
    }
    state = SyncCoordinatorState(
      phase: result.hasFailures
          ? SyncCoordinatorPhase.failed
          : SyncCoordinatorPhase.synced,
      result: result,
    );
    return result;
  }
}
