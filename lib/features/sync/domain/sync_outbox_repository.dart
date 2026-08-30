import 'sync_operation.dart';
import 'sync_transport.dart';

/// Local-first access to the durable sync outbox, the locally editable rows it
/// tracks, and the per-user pull cursor.
///
/// This contract keeps the sync engine independent of Drift. Every mutating
/// method applies its outbox and domain-row changes in one database
/// transaction so an interruption never leaves a row marked synced while its
/// outbox item still exists, or vice versa.
///
/// Rejected and retry-exhausted operations are never deleted automatically:
/// they are parked for an explicit, recoverable retry via
/// [retryFailedOperations].
abstract interface class SyncOutboxRepository {
  /// Due outbox items for the bound user, ordered by [nextAttemptAt]. The
  /// engine re-sorts these by dependency priority before pushing.
  Future<List<SyncOperation>> dueOperations();

  /// Records a confirmed, idempotent acceptance: removes the outbox item and,
  /// when no newer outbox item exists for the same entity, marks its domain
  /// row(s) `synced`. Repeated acknowledgement is a no-op.
  Future<void> markSynced(SyncOperation operation);

  /// Records a transient failure: bumps the attempt count, schedules the next
  /// attempt, and marks the domain row `failed` with a recoverable diagnostic.
  Future<void> markRetryableFailure(
    SyncOperation operation, {
    required int nextAttemptCount,
    required DateTime nextAttemptAt,
  });

  /// Parks the operation as permanently rejected: it is retained (never
  /// deleted) and marked non-due, and the domain row is marked `failed` with
  /// the provided stable [code].
  Future<void> markRejected(SyncOperation operation, {required String code});

  /// Retains the operation without consuming retry budget because the
  /// transport is unconfigured or the bound user is not authenticated.
  Future<void> markUnavailable(SyncOperation operation);

  /// The last server-issued pull cursor for the bound user.
  Future<int> pullCursor();

  Future<void> storePullCursor(int cursor);

  /// Reconciles server-authored pull changes (saved-routine tombstones and
  /// projections) without overwriting newer local pending writes.
  Future<void> applyPullChanges(Iterable<SyncPullChange> changes);

  /// Persists server-authoritative projections, overriding any local
  /// projection with the same [SyncProjection.projectionType].
  Future<void> storeProjections(Iterable<SyncProjection> projections);

  /// Re-enqueues parked (rejected/exhausted) operations for an explicit retry
  /// and returns how many were reset to `pending`.
  Future<int> retryFailedOperations();
}
