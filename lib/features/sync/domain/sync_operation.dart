/// One durable outbox operation, ready to be pushed to the trusted sync API.
///
/// [outboxId] is the local queue row identity used for idempotent
/// acknowledgement. [operationId] is the client-generated stable UUID that
/// identifies the operation across retries and drives server idempotency; it is
/// persisted so a retry reuses the exact same id. [kind] is the RAHA-025 wire
/// operation kind, [entityType]/[entityId] identify the locally editable domain
/// row(s) this operation mutates, and [sequence] orders operations within a
/// single entity (session steps by `position_snapshot`).
final class SyncOperation {
  const SyncOperation({
    required this.outboxId,
    required this.operationId,
    required this.kind,
    required this.entityType,
    required this.entityId,
    required this.sequence,
    required this.payloadJson,
    required this.attemptCount,
    required this.createdAt,
  });

  final int outboxId;
  final String operationId;
  final String kind;
  final String entityType;
  final String entityId;
  final int sequence;
  final String payloadJson;
  final int attemptCount;
  final DateTime createdAt;
}
