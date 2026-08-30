import 'sync_operation.dart';

/// Stable, language-neutral sync diagnostic codes. These are surfaced as
/// `lastSyncError` on locally editable rows and never as raw server responses.
abstract final class SyncDiagnostics {
  static const String networkUnavailable = 'network_unavailable';
  static const String validationRejected = 'validation_rejected';
  static const String retryExhausted = 'retry_exhausted';
  static const String unmappedId = 'unmapped_id';
  static const String unsupportedOperation = 'unsupported_operation';
  static const String notConfigured = 'not_configured';
  static const String authenticationRequired = 'authentication_required';
}

/// Application-owned, injectable boundary to the trusted user-data sync API.
///
/// The concrete implementation wraps `sync_push_user_data` and
/// `sync_pull_user_data`. Tests inject fakes; no caller identity is ever sent —
/// the backend derives the owner from the authenticated session.
abstract interface class SyncTransport {
  /// Pushes one operation and reports its outcome.
  ///
  /// Implementations must be idempotent: the server treats a repeated identical
  /// operation (same stable operation id and content) as success.
  Future<SyncPushResponse> push(SyncOperation operation);

  /// Pulls server-authored changes newer than [afterCursor] for the bound user.
  Future<SyncPullResponse> pull({required int afterCursor, int limit});
}

/// The outcome of a single pushed operation.
sealed class SyncPushResponse {
  const SyncPushResponse();
}

/// The server accepted the operation. Carries the authoritative pull cursor and
/// projections (points, streak, achievements, entitlements) that override local
/// state.
final class SyncAccepted extends SyncPushResponse {
  const SyncAccepted({this.projections = const [], this.cursor});

  final List<SyncProjection> projections;
  final int? cursor;
}

/// The server permanently rejected the operation; retrying is pointless unless
/// the underlying cause (a mapping, a policy version) changes.
final class SyncRejected extends SyncPushResponse {
  const SyncRejected(this.code);

  /// Stable, language-neutral diagnostic code.
  final String code;
}

/// A transient failure; the engine will retry with bounded backoff.
final class SyncRetryableFailure extends SyncPushResponse {
  const SyncRetryableFailure();
}

/// The transport is not configured or the bound user is not authenticated.
/// The outbox item is retained without consuming retry budget and without being
/// dropped.
final class SyncUnavailable extends SyncPushResponse {
  const SyncUnavailable();
}

/// The outcome of one pull pass.
sealed class SyncPullResponse {
  const SyncPullResponse();
}

final class SyncPullSuccess extends SyncPullResponse {
  const SyncPullSuccess({
    required this.changes,
    required this.cursor,
    this.projections = const [],
  });

  final List<SyncPullChange> changes;
  final int cursor;
  final List<SyncProjection> projections;
}

final class SyncPullRetryable extends SyncPullResponse {
  const SyncPullRetryable();
}

final class SyncPullUnavailable extends SyncPullResponse {
  const SyncPullUnavailable();
}

/// One server-authored change returned by `sync_pull_user_data`.
final class SyncPullChange {
  const SyncPullChange({
    required this.cursor,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.occurredAt,
  });

  final int cursor;
  final String entityType;
  final String entityId;

  /// `upsert`, `delete`, or `finalize`.
  final String operation;
  final String payloadJson;
  final DateTime occurredAt;
}

/// A server-authoritative, derived projection for the bound user.
///
/// These always override local projections after a successful sync; the client
/// never treats its own computation as the authority for rewards, streaks,
/// achievements, or entitlements.
final class SyncProjection {
  const SyncProjection({
    required this.projectionType,
    required this.payloadJson,
    required this.serverUpdatedAt,
  });

  final String projectionType;
  final String payloadJson;
  final DateTime serverUpdatedAt;
}
