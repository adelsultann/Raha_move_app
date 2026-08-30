import 'backoff_policy.dart';
import 'sync_outbox_repository.dart';
import 'sync_operation.dart';
import 'sync_priority.dart';
import 'sync_transport.dart';

/// The outcome of one synchronization pass.
final class SyncResult {
  const SyncResult({
    required this.succeeded,
    required this.retryableFailures,
    required this.rejected,
    required this.skipped,
    required this.pulledChanges,
    required this.pullRetryable,
    required this.projections,
  });

  final int succeeded;
  final int retryableFailures;
  final int rejected;

  /// Operations retained because the transport was unconfigured or the user
  /// was unauthenticated. They consumed no retry budget and were not dropped.
  final int skipped;

  final int pulledChanges;
  final bool pullRetryable;

  /// Authoritative projections returned by the transport and persisted this
  /// pass. They override local projections after sync.
  final List<SyncProjection> projections;

  /// Whether any operation failed this pass (recoverable, not fatal).
  bool get hasFailures =>
      retryableFailures > 0 || rejected > 0 || pullRetryable;

  /// Whether at least one operation is scheduled or parked for a retry.
  bool get hasPendingRetry => retryableFailures > 0 || rejected > 0;
}

/// Pushes the durable outbox to the trusted sync API in dependency order, then
/// pulls server-authored changes and projections.
///
/// The engine never blocks or mutates normal local use: on a transient failure
/// it records the attempt and schedules the next one with bounded exponential
/// backoff; the domain row is only marked `failed` with a recoverable
/// diagnostic. Outbox items are removed only after a confirmed acceptance, and
/// a permanent rejection parks the item (it is never deleted) for an explicit
/// manual retry via [retry].
final class UserDataSyncEngine {
  UserDataSyncEngine({
    required this.outbox,
    required this.transport,
    this.backoff = const BackoffPolicy(),
    DateTime Function()? clock,
  }) : _clock = clock ?? _systemClock;

  final SyncOutboxRepository outbox;
  final SyncTransport transport;
  final BackoffPolicy backoff;
  final DateTime Function() _clock;

  static DateTime _systemClock() => DateTime.now();

  /// Re-enqueues parked operations and runs one pass. This is the explicit,
  /// recoverable retry entry point: it never deletes parked data on its own.
  Future<SyncResult> retry() async {
    await outbox.retryFailedOperations();
    return synchronize();
  }

  /// Runs one pass over the due outbox and then pulls.
  ///
  /// Each operation is processed independently so one failure cannot abort the
  /// batch. A thrown transport exception is treated as a retryable failure.
  Future<SyncResult> synchronize() async {
    final due = await outbox.dueOperations();
    final ordered = _orderByDependency(due);

    var succeeded = 0;
    var retryableFailures = 0;
    var rejected = 0;
    var skipped = 0;
    final storedProjections = <SyncProjection>[];

    for (final operation in ordered) {
      final response = await _push(operation);
      switch (response) {
        case SyncAccepted(:final projections, :final cursor):
          await outbox.markSynced(operation);
          if (projections.isNotEmpty) {
            await outbox.storeProjections(projections);
            storedProjections.addAll(projections);
          }
          if (cursor != null) {
            await outbox.storePullCursor(cursor);
          }
          succeeded++;
        case SyncRejected(:final code):
          await outbox.markRejected(operation, code: code);
          rejected++;
        case SyncRetryableFailure():
          final nextAttemptCount = operation.attemptCount + 1;
          if (backoff.isExhausted(nextAttemptCount)) {
            await outbox.markRejected(
              operation,
              code: SyncDiagnostics.retryExhausted,
            );
            rejected++;
          } else {
            final nextAttemptAt = _clock().toUtc().add(
              backoff.delayForAttempt(nextAttemptCount),
            );
            await outbox.markRetryableFailure(
              operation,
              nextAttemptCount: nextAttemptCount,
              nextAttemptAt: nextAttemptAt,
            );
            retryableFailures++;
          }
        case SyncUnavailable():
          // Retain without consuming budget; nothing more will succeed while
          // the transport is unconfigured or the user is signed out.
          await outbox.markUnavailable(operation);
          skipped++;
      }
    }

    final (pulledChanges, pullRetryable) = await _pull(storedProjections);

    return SyncResult(
      succeeded: succeeded,
      retryableFailures: retryableFailures,
      rejected: rejected,
      skipped: skipped,
      pulledChanges: pulledChanges,
      pullRetryable: pullRetryable,
      projections: storedProjections,
    );
  }

  Future<SyncPushResponse> _push(SyncOperation operation) async {
    try {
      return await transport.push(operation);
    } catch (_) {
      return const SyncRetryableFailure();
    }
  }

  Future<(int, bool)> _pull(List<SyncProjection> storedProjections) async {
    final cursor = await outbox.pullCursor();
    final SyncPullResponse response;
    try {
      response = await transport.pull(afterCursor: cursor);
    } catch (_) {
      return (0, true);
    }
    switch (response) {
      case SyncPullSuccess(:final changes, :final cursor, :final projections):
        if (changes.isNotEmpty) {
          await outbox.applyPullChanges(changes);
        }
        await outbox.storePullCursor(cursor);
        if (projections.isNotEmpty) {
          await outbox.storeProjections(projections);
          storedProjections.addAll(projections);
        }
        return (changes.length, false);
      case SyncPullRetryable():
        return (0, true);
      case SyncPullUnavailable():
        return (0, false);
    }
  }

  /// Stable dependency ordering: kind priority first, then per-entity
  /// sequence, then creation time, then the local outbox id. This guarantees a
  /// parent (check-in) flushes before its children (recommendation, session,
  /// feedback) and that session steps and finalization keep positional order.
  List<SyncOperation> _orderByDependency(List<SyncOperation> operations) {
    final ordered = List<SyncOperation>.of(operations);
    ordered.sort((a, b) {
      final byPriority = syncPriorityForKind(a.kind)
          .compareTo(syncPriorityForKind(b.kind));
      if (byPriority != 0) return byPriority;
      final bySequence = a.sequence.compareTo(b.sequence);
      if (bySequence != 0) return bySequence;
      final byCreated = a.createdAt.compareTo(b.createdAt);
      if (byCreated != 0) return byCreated;
      return a.outboxId.compareTo(b.outboxId);
    });
    return ordered;
  }
}
