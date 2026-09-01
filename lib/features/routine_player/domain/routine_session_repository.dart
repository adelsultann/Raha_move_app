import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_session_repository.freezed.dart';

/// The versioned RAHA-001 completion policy recorded on every durable session.
const String kRoutineCompletionPolicyVersion = 'raha_001_v1';

/// Pure RAHA-001 completion rule: a terminal session is `completed` only when
/// its credited duration reaches 80% of the target and its skipped steps stay
/// within the floor(20%) allowance. This mirrors the data-boundary evaluation
/// exactly so the player's optimistic terminal state matches the durable row.
bool qualifiesForCompletion({
  required int actualDurationSeconds,
  required int targetDurationSeconds,
  required int stepsSkipped,
  required int totalSteps,
}) {
  if (targetDurationSeconds <= 0) return false;
  final durationQualifies =
      actualDurationSeconds * 100 >= targetDurationSeconds * 80;
  final skipsQualify = stepsSkipped <= totalSteps ~/ 5;
  return durationQualifies && skipsQualify;
}

/// A durable, provider-independent snapshot of one routine step. Used both when
/// writing progress (the state to persist) and when reading it back (the state
/// restored from the local store).
@freezed
abstract class RoutineStepSnapshot with _$RoutineStepSnapshot {
  const factory RoutineStepSnapshot({
    required String stepId,
    required String exerciseId,
    required int position,
    required String status,
    required int targetDurationSeconds,
    required int activeDurationSeconds,
    required bool skipRequested,
  }) = _RoutineStepSnapshot;
}

/// A durable, provider-independent snapshot of one routine session. Restored
/// sessions are mapped back to the in-memory playback model from this record.
@freezed
abstract class RoutineSessionSnapshot with _$RoutineSessionSnapshot {
  const factory RoutineSessionSnapshot({
    required String sessionId,
    required String routineId,
    required int routineVersion,
    String? recommendationId,
    required DateTime startedAt,
    required String status,
    int? currentStepPosition,
    int? currentStepActiveSeconds,
    required List<RoutineStepSnapshot> steps,
  }) = _RoutineSessionSnapshot;
}

/// App-owned boundary for persisting routine sessions locally (RAHA-052).
///
/// Writes are committed atomically with their synchronization outbox operation
/// by the data layer; the local-only playback cursor is written separately so
/// ticks never create duplicate session or reward records.
abstract interface class RoutineSessionRepository {
  /// Creates or updates one session and its step snapshots. The same
  /// [sessionId] upserts in place, so retries and duplicate finish taps cannot
  /// create a second session.
  ///
  /// When [explicitlyAbandoned] is true the session terminalizes as `abandoned`
  /// regardless of the RAHA-001 completion threshold, so an explicit
  /// abandonment can never award completion progress.
  Future<void> save({
    required String userId,
    required String sessionId,
    required String routineId,
    required int routineVersion,
    String? recommendationId,
    required DateTime startedAt,
    required List<RoutineStepSnapshot> steps,
    int? currentStepPosition,
    int? currentStepActiveSeconds,
    bool explicitlyAbandoned = false,
  });

  /// Advances the local-only playback cursor for an in-progress session. Never
  /// enqueues a sync operation and never counts toward completion.
  Future<void> saveCursor({
    required String userId,
    required String sessionId,
    required int currentStepPosition,
    required int activeSeconds,
  });

  /// The most recently active in-progress session for [userId], or null.
  Future<RoutineSessionSnapshot?> resumable({required String userId});

  /// A specific session by id, or null when absent or not owned by [userId].
  Future<RoutineSessionSnapshot?> findById({
    required String userId,
    required String sessionId,
  });

  /// Idempotently abandons in-progress sessions with no credited activity for
  /// 24 hours. Called before any resumable lookup/restore so stale sessions can
  /// never block or be restored.
  Future<void> expireInactiveSessions({required String userId});
}
