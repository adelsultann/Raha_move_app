import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/sync_operation.dart';
import '../domain/sync_outbox_repository.dart';
import '../domain/sync_transport.dart';

/// Drift-backed [SyncOutboxRepository].
///
/// Reads the durable outbox through the existing [LocalUserDataRepository]
/// API and applies acknowledgement, backoff, parking, projection, cursor, and
/// pull-reconciliation writes against the same database. Every mutating method
/// commits its outbox and domain-row changes in one transaction.
final class DriftSyncOutboxRepository implements SyncOutboxRepository {
  DriftSyncOutboxRepository(
    this._database, {
    required this.activeUserId,
    DateTime Function()? clock,
    String Function()? operationIdGenerator,
    this.appVersion = '1.0.0',
  }) : _clock = clock ?? _systemClock,
       _userData = LocalUserDataRepository(
         _database,
         activeUserId: activeUserId,
         clock: clock ?? _systemClock,
         operationIdGenerator: operationIdGenerator,
         appVersion: appVersion,
       );

  final AppDatabase _database;
  final String activeUserId;
  final String appVersion;
  final DateTime Function() _clock;
  final LocalUserDataRepository _userData;

  static DateTime _systemClock() => DateTime.now();

  @override
  Future<List<SyncOperation>> dueOperations() async {
    final rows = await _userData.dueOutbox();
    return rows.map(_toOperation).toList();
  }

  @override
  Future<void> markSynced(SyncOperation operation) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.syncOutbox,
      )..where((r) => r.id.equals(operation.outboxId))).go();
      final remaining = await _hasPendingOutboxItem(operation);
      if (!remaining) {
        await _writeDomainState(
          operation,
          syncState: SyncState.synced,
          lastSyncError: null,
        );
      }
    });
  }

  @override
  Future<void> markRetryableFailure(
    SyncOperation operation, {
    required int nextAttemptCount,
    required DateTime nextAttemptAt,
  }) {
    return _database.transaction(() async {
      await (_database.update(
        _database.syncOutbox,
      )..where((r) => r.id.equals(operation.outboxId))).write(
        SyncOutboxCompanion(
          attemptCount: Value(nextAttemptCount),
          nextAttemptAt: Value(nextAttemptAt),
        ),
      );
      await _writeDomainState(
        operation,
        syncState: SyncState.failed,
        lastSyncError: SyncDiagnosticCode.networkUnavailable,
      );
    });
  }

  @override
  Future<void> markRejected(SyncOperation operation, {required String code}) {
    return _database.transaction(() async {
      // Park, never delete: the operation stays recoverable for a manual retry.
      await (_database.update(
        _database.syncOutbox,
      )..where((r) => r.id.equals(operation.outboxId))).write(
        const SyncOutboxCompanion(status: Value(OutboxStatus.rejected)),
      );
      await _writeDomainState(
        operation,
        syncState: SyncState.failed,
        lastSyncError: _diagnosticFor(code),
      );
    });
  }

  @override
  Future<void> markUnavailable(SyncOperation operation) async {
    // Retain the item untouched: an unconfigured or unauthenticated transport
    // must not consume retry budget and must not drop the operation.
  }

  @override
  Future<int> pullCursor() => _userData.pullCursor();

  @override
  Future<void> storePullCursor(int cursor) => _userData.storePullCursor(cursor);

  @override
  Future<void> applyPullChanges(Iterable<SyncPullChange> changes) async {
    final list = changes.toList();
    if (list.isEmpty) return;
    await _database.transaction(() async {
      for (final change in list) {
        switch (change.entityType) {
          case 'check_in':
            await _applyCheckInChange(change);
          case 'recommendation':
            await _applyRecommendationChange(change);
          case 'session':
            await _applySessionChange(change);
          case 'session_step':
            await _applySessionStepChange(change);
          case 'feedback':
            await _applyFeedbackChange(change);
          case 'saved_routine':
            await _applySavedRoutineChange(change);
          default:
            // Unknown entity types are additive; ignore without touching data.
            break;
        }
      }
    });
  }

  @override
  Future<void> storeProjections(Iterable<SyncProjection> projections) async {
    if (projections.isEmpty) return;
    await _database.batch(
      (b) => b.insertAllOnConflictUpdate(_database.localProgressProjections, [
        for (final projection in projections)
          LocalProgressProjectionsCompanion.insert(
            userId: activeUserId,
            projectionType: projection.projectionType,
            payloadJson: projection.payloadJson,
            serverUpdatedAt: projection.serverUpdatedAt.toUtc(),
          ),
      ]),
    );
  }

  @override
  Future<int> retryFailedOperations() async {
    final parked = await _userData.parkedOutbox();
    final keys = parked.map((row) => (row.entityType, row.entityId)).toSet();
    var rebuilt = 0;
    for (final (entityType, entityId) in keys) {
      if (await _userData.rebuildOutboxOperation(entityType, entityId)) {
        rebuilt++;
      }
    }
    return rebuilt;
  }

  SyncOperation _toOperation(SyncOutboxData row) => SyncOperation(
    outboxId: row.id,
    operationId: row.operationId,
    kind: row.kind,
    entityType: row.entityType,
    entityId: row.entityId,
    sequence: row.sequence,
    payloadJson: row.payloadJson,
    attemptCount: row.attemptCount,
    createdAt: row.createdAt,
  );

  Future<bool> _hasPendingOutboxItem(SyncOperation operation) async {
    final remaining =
        await (_database.select(_database.syncOutbox)..where(
              (r) =>
                  r.ownerUserId.equals(activeUserId) &
                  r.status.equalsValue(OutboxStatus.pending) &
                  r.entityType.equals(operation.entityType) &
                  r.entityId.equals(operation.entityId),
            ))
            .get();
    return remaining.isNotEmpty;
  }

  /// Applies [syncState] and [lastSyncError] to the locally editable row(s)
  /// that back [operation]. `serverUpdatedAt` is set to now only when the row
  /// becomes `synced`; on failure it is left untouched so the last accepted
  /// server timestamp is preserved.
  Future<void> _writeDomainState(
    SyncOperation operation, {
    required SyncState syncState,
    required SyncDiagnosticCode? lastSyncError,
  }) async {
    final now = _clock().toUtc();
    final serverUpdatedAt = syncState == SyncState.synced
        ? Value<DateTime?>(now)
        : const Value<DateTime?>.absent();
    final error = Value<SyncDiagnosticCode?>(lastSyncError);

    switch (operation.entityType) {
      case 'check_in':
        await (_database.update(
          _database.localCheckIns,
        )..where((r) => r.id.equals(operation.entityId))).write(
          LocalCheckInsCompanion(
            syncState: Value(syncState),
            serverUpdatedAt: serverUpdatedAt,
            lastSyncError: error,
          ),
        );
      case 'recommendation':
        await (_database.update(
          _database.localRecommendations,
        )..where((r) => r.id.equals(operation.entityId))).write(
          LocalRecommendationsCompanion(
            syncState: Value(syncState),
            serverUpdatedAt: serverUpdatedAt,
            lastSyncError: error,
          ),
        );
      case 'routine_session':
        // A session carries its start, steps, and finalization as separate
        // operations; both the session and its steps are marked together only
        // once no pending operation for the session remains.
        await (_database.update(
          _database.localRoutineSessions,
        )..where((r) => r.id.equals(operation.entityId))).write(
          LocalRoutineSessionsCompanion(
            syncState: Value(syncState),
            serverUpdatedAt: serverUpdatedAt,
            lastSyncError: error,
          ),
        );
        await (_database.update(
          _database.localSessionSteps,
        )..where((r) => r.sessionId.equals(operation.entityId))).write(
          LocalSessionStepsCompanion(
            syncState: Value(syncState),
            serverUpdatedAt: serverUpdatedAt,
            lastSyncError: error,
          ),
        );
      case 'session_feedback':
        await (_database.update(
          _database.localSessionFeedback,
        )..where((r) => r.sessionId.equals(operation.entityId))).write(
          LocalSessionFeedbackCompanion(
            syncState: Value(syncState),
            serverUpdatedAt: serverUpdatedAt,
            lastSyncError: error,
          ),
        );
      case 'saved_routine':
        await (_database.update(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) &
                  r.routineId.equals(operation.entityId),
            ))
            .write(
              LocalSavedRoutinesCompanion(
                syncState: Value(syncState),
                serverUpdatedAt: serverUpdatedAt,
                lastSyncError: error,
              ),
            );
      default:
        // Unknown entity type: leave the domain row untouched; the outbox item
        // is still acknowledged so a future additive entity cannot wedge the
        // queue.
        break;
    }
  }

  Future<void> _applySavedRoutineChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final remoteRoutineId = payload['routine_id'];
    final saved = payload['saved'] == true;
    final operationAt = DateTime.tryParse(
      payload['operation_at']?.toString() ?? '',
    );
    if (remoteRoutineId is! String || operationAt == null) return;

    final localId = await _userData.localIdForRemote(
      RemoteIdMappingKind.routine,
      remoteRoutineId,
    );
    if (localId == null) return;

    // Never overwrite a newer local pending/rejected write with a pulled
    // tombstone.
    if (await _hasPendingOrRejectedOutbox('saved_routine', localId)) return;

    final existing =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) =>
                  r.userId.equals(activeUserId) & r.routineId.equals(localId),
            ))
            .getSingleOrNull();
    await _database
        .into(_database.localSavedRoutines)
        .insertOnConflictUpdate(
          LocalSavedRoutinesCompanion.insert(
            userId: activeUserId,
            routineId: localId,
            savedAt: existing?.savedAt ?? operationAt,
            deletedAt: Value<DateTime?>(saved ? null : operationAt),
            syncState: const Value(SyncState.synced),
            localUpdatedAt: operationAt,
            serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
            lastSyncError: const Value<SyncDiagnosticCode?>(null),
          ),
        );
  }

  Future<void> _applyCheckInChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final id = payload['id'];
    if (id is! String || id.isEmpty) return;
    if (await _hasPendingOrRejectedOutbox('check_in', id)) return;

    final bodyState = payload['body_state'];
    if (bodyState is! String ||
        !const {'comfortable', 'stiff', 'tired', 'tense'}.contains(bodyState)) {
      return;
    }
    final startedAt = _parseIso(payload['started_at']);
    final availableMinutes = _asInt(payload['available_minutes']);
    if (startedAt == null ||
        availableMinutes == null ||
        !const {3, 5, 10, 15}.contains(availableMinutes)) {
      return;
    }
    final goalKey = await _resolveLocal(
      RemoteIdMappingKind.taxonomy,
      payload['goal_id'],
    );
    if (goalKey == null) return; // goal_id is required; unmapped means skip.
    final positionKey = payload['position_id'] == null
        ? null
        : await _resolveLocal(
            RemoteIdMappingKind.taxonomy,
            payload['position_id'],
          );
    if (payload['position_id'] != null && positionKey == null) return;

    await _database
        .into(_database.localCheckIns)
        .insertOnConflictUpdate(
          LocalCheckInsCompanion.insert(
            id: id,
            userId: activeUserId,
            bodyState: bodyState,
            goalKey: goalKey,
            availableMinutes: availableMinutes,
            startedAt: startedAt,
            localUpdatedAt: change.occurredAt.toUtc(),
          ).copyWith(
            positionKey: Value(positionKey),
            completedAt: Value(_parseIso(payload['completed_at'])),
            syncState: const Value(SyncState.synced),
            serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
            lastSyncError: const Value<SyncDiagnosticCode?>(null),
          ),
        );

    await _applyCheckInBodyAreas(id, payload);
  }

  /// Reconciles `body_area_ids` when the pull feed carries them; otherwise the
  /// local rows are left untouched (the current feed has no body-area column).
  Future<void> _applyCheckInBodyAreas(
    String checkInId,
    Map<String, dynamic> payload,
  ) async {
    final raw = payload['body_area_ids'];
    if (raw is! List) return;
    final keys = <String>[];
    for (final item in raw) {
      final key = await _resolveLocal(RemoteIdMappingKind.taxonomy, item);
      if (key == null) return; // an unmapped area keeps the whole set intact.
      keys.add(key);
    }
    await (_database.delete(
      _database.localCheckInBodyAreas,
    )..where((r) => r.checkInId.equals(checkInId))).go();
    if (keys.isEmpty) return;
    await _database.batch(
      (b) => b.insertAll(_database.localCheckInBodyAreas, [
        for (final key in keys)
          LocalCheckInBodyAreasCompanion.insert(
            checkInId: checkInId,
            bodyAreaKey: key,
          ),
      ]),
    );
  }

  Future<void> _applyRecommendationChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final id = payload['id'];
    if (id is! String || id.isEmpty) return;
    if (await _hasPendingOrRejectedOutbox('recommendation', id)) return;

    final checkInId = payload['check_in_id'];
    final routineId = payload['routine_id'];
    final engineVersion = payload['engine_version'];
    final shownAt = _parseIso(payload['shown_at']);
    final rank = _asInt(payload['rank']);
    final score = _asInt(payload['score']);
    if (checkInId is! String ||
        routineId is! String ||
        engineVersion is! String ||
        shownAt == null ||
        rank == null ||
        score == null) {
      return;
    }
    final localRoutineId = await _resolveLocal(
      RemoteIdMappingKind.routine,
      routineId,
    );
    if (localRoutineId == null) return;

    final parentExists =
        await (_database.select(
          _database.localCheckIns,
        )..where((r) => r.id.equals(checkInId))).getSingleOrNull() !=
        null;
    if (!parentExists) return;

    final reasonCodes = payload['reason_codes'];
    final reasonCodesJson = reasonCodes is List
        ? jsonEncode(reasonCodes.whereType<String>().toList())
        : '[]';

    await _database
        .into(_database.localRecommendations)
        .insertOnConflictUpdate(
          LocalRecommendationsCompanion.insert(
            id: id,
            userId: activeUserId,
            checkInId: checkInId,
            routineId: localRoutineId,
            engineVersion: engineVersion,
            // Wire rank is 1..100; the local model is 0-based.
            rank: rank - 1,
            score: score,
            reasonCodesJson: reasonCodesJson,
            shownAt: shownAt,
            localUpdatedAt: change.occurredAt.toUtc(),
          ).copyWith(
            acceptedAt: Value(_parseIso(payload['accepted_at'])),
            rejectedAt: Value(_parseIso(payload['rejected_at'])),
            rejectionReason: Value(payload['rejection_reason']?.toString()),
            syncState: const Value(SyncState.synced),
            serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
            lastSyncError: const Value<SyncDiagnosticCode?>(null),
          ),
        );
  }

  Future<void> _applySessionChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final id = payload['id'];
    if (id is! String || id.isEmpty) return;
    if (await _hasPendingOrRejectedOutbox('routine_session', id)) return;

    final existing =
        await (_database.select(_database.localRoutineSessions)
              ..where((r) => r.id.equals(id) & r.userId.equals(activeUserId)))
            .getSingleOrNull();
    // The change feed carries only `{id}` for a start and `{id,status}` for a
    // finalize; a session that is not already local cannot be reconstructed.
    if (existing == null) return;

    if (change.operation == 'finalize') {
      final status = payload['status'];
      if (status != 'completed' && status != 'abandoned') return;
      // The server's terminal decision is authoritative and never regresses to
      // `in_progress`.
      await (_database.update(
        _database.localRoutineSessions,
      )..where((r) => r.id.equals(id))).write(
        LocalRoutineSessionsCompanion(
          status: Value(status),
          completedAt: Value<DateTime?>(
            status == 'completed'
                ? change.occurredAt.toUtc()
                : (existing.completedAt ?? change.occurredAt.toUtc()),
          ),
          syncState: const Value(SyncState.synced),
          serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
          lastSyncError: const Value<SyncDiagnosticCode?>(null),
        ),
      );
    } else {
      // A `session_start` echo from the same or another device: acknowledge it
      // as synced without mutating playback progress.
      await (_database.update(
        _database.localRoutineSessions,
      )..where((r) => r.id.equals(id))).write(
        LocalRoutineSessionsCompanion(
          syncState: const Value(SyncState.synced),
          serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
          lastSyncError: const Value<SyncDiagnosticCode?>(null),
        ),
      );
    }
  }

  Future<void> _applySessionStepChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final sessionId = payload['session_id'];
    final routineStepId = payload['routine_step_id'];
    if (sessionId is! String || routineStepId is! String) return;
    // A step belongs to its session; guard the session's own pending writes.
    if (await _hasPendingOrRejectedOutbox('routine_session', sessionId)) return;

    final exerciseId = await _resolveLocal(
      RemoteIdMappingKind.exercise,
      payload['exercise_id_snapshot'],
    );
    final position = _asInt(payload['position_snapshot']);
    final target = _asInt(payload['target_duration_seconds']);
    final active = _asInt(payload['active_duration_seconds']);
    final status = payload['status'];
    if (exerciseId == null ||
        position == null ||
        target == null ||
        active == null ||
        status is! String) {
      return;
    }
    if (position <= 0 ||
        target <= 0 ||
        active < 0 ||
        active > target ||
        !const {
          'pending',
          'completed',
          'partial',
          'skipped',
        }.contains(status)) {
      return;
    }

    final sessionExists =
        await (_database.select(_database.localRoutineSessions)..where(
              (r) => r.id.equals(sessionId) & r.userId.equals(activeUserId),
            ))
            .getSingleOrNull() !=
        null;
    if (!sessionExists) return;

    await _database
        .into(_database.localSessionSteps)
        .insertOnConflictUpdate(
          LocalSessionStepsCompanion.insert(
            sessionId: sessionId,
            routineStepId: routineStepId,
            exerciseIdSnapshot: exerciseId,
            positionSnapshot: position,
            status: status,
            targetDurationSeconds: target,
            localUpdatedAt: change.occurredAt.toUtc(),
          ).copyWith(
            activeDurationSeconds: Value(active),
            skipRequested: Value(payload['skip_requested'] == true),
            startedAt: Value(_parseIso(payload['started_at'])),
            finishedAt: Value(_parseIso(payload['finished_at'])),
            syncState: const Value(SyncState.synced),
            serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
            lastSyncError: const Value<SyncDiagnosticCode?>(null),
          ),
        );
  }

  Future<void> _applyFeedbackChange(SyncPullChange change) async {
    final payload = _decodePayload(change.payloadJson);
    if (payload == null) return;
    final sessionId = payload['session_id'];
    final rating = payload['rating'];
    if (sessionId is! String || rating is! String) return;
    if (await _hasPendingOrRejectedOutbox('session_feedback', sessionId)) {
      return;
    }
    if (!const {
      'much_better',
      'little_better',
      'same',
      'less_comfortable',
    }.contains(rating)) {
      return;
    }

    final sessionExists =
        await (_database.select(_database.localRoutineSessions)..where(
              (r) => r.id.equals(sessionId) & r.userId.equals(activeUserId),
            ))
            .getSingleOrNull() !=
        null;
    if (!sessionExists) return;

    final uncomfortable = payload['uncomfortable_exercise_id'] == null
        ? null
        : await _resolveLocal(
            RemoteIdMappingKind.exercise,
            payload['uncomfortable_exercise_id'],
          );
    if (payload['uncomfortable_exercise_id'] != null && uncomfortable == null) {
      return;
    }

    await _database
        .into(_database.localSessionFeedback)
        .insertOnConflictUpdate(
          LocalSessionFeedbackCompanion.insert(
            sessionId: sessionId,
            userId: activeUserId,
            rating: rating,
            createdAt:
                _parseIso(payload['created_at']) ?? change.occurredAt.toUtc(),
            localUpdatedAt: change.occurredAt.toUtc(),
          ).copyWith(
            uncomfortableExerciseId: Value(uncomfortable),
            syncState: const Value(SyncState.synced),
            serverUpdatedAt: Value<DateTime?>(change.occurredAt.toUtc()),
            lastSyncError: const Value<SyncDiagnosticCode?>(null),
          ),
        );
  }

  Map<String, dynamic>? _decodePayload(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  DateTime? _parseIso(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  Future<String?> _resolveLocal(String kind, Object? remoteId) async {
    if (remoteId is! String || remoteId.isEmpty) return null;
    return _userData.localIdForRemote(kind, remoteId);
  }

  /// Whether a locally editable entity still has a pending or parked (rejected)
  /// outbox operation. Pull reconciliation must never overwrite these newer,
  /// unsent local writes.
  Future<bool> _hasPendingOrRejectedOutbox(
    String entityType,
    String entityId,
  ) async {
    final rows =
        await (_database.select(_database.syncOutbox)..where(
              (r) =>
                  r.ownerUserId.equals(activeUserId) &
                  r.entityType.equals(entityType) &
                  r.entityId.equals(entityId) &
                  (r.status.equalsValue(OutboxStatus.pending) |
                      r.status.equalsValue(OutboxStatus.rejected)),
            ))
            .get();
    return rows.isNotEmpty;
  }

  SyncDiagnosticCode _diagnosticFor(String code) {
    switch (code) {
      case SyncDiagnostics.networkUnavailable:
        return SyncDiagnosticCode.networkUnavailable;
      case SyncDiagnostics.validationRejected:
        return SyncDiagnosticCode.validationRejected;
      case SyncDiagnostics.retryExhausted:
        return SyncDiagnosticCode.retryExhausted;
      case SyncDiagnostics.unmappedId:
        return SyncDiagnosticCode.unmappedId;
      case SyncDiagnostics.unsupportedOperation:
        return SyncDiagnosticCode.unsupportedOperation;
      default:
        return SyncDiagnosticCode.validationRejected;
    }
  }
}
