import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/routine_session_repository.dart';

/// Drift-backed [RoutineSessionRepository].
///
/// Writes delegate to the RAHA-023 local user-data repository so a session and
/// its step snapshots commit in one transaction with their outbox operation.
/// Reads map durable rows back to provider-independent snapshots.
final class DriftRoutineSessionRepository implements RoutineSessionRepository {
  DriftRoutineSessionRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<void> save({
    required String userId,
    required String sessionId,
    required String routineId,
    required int routineVersion,
    String? recommendationId,
    String source = 'recommendation',
    required DateTime startedAt,
    required List<RoutineStepSnapshot> steps,
    int? currentStepPosition,
    int? currentStepActiveSeconds,
    bool explicitlyAbandoned = false,
  }) {
    final now = _clock().toUtc();
    final target = steps.fold<int>(
      0,
      (sum, step) => sum + step.targetDurationSeconds,
    );
    return LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveSessionWithSteps(
      session: LocalRoutineSessionsCompanion.insert(
        id: sessionId,
        userId: userId,
        routineId: routineId,
        routineVersion: routineVersion,
        recommendationId: Value(recommendationId),
        status: 'in_progress',
        startedAt: startedAt,
        targetDurationSeconds: target,
        actualDurationSeconds: 0,
        totalSteps: steps.length,
        completionPolicyVersion: kRoutineCompletionPolicyVersion,
        source: source,
        localUpdatedAt: now,
      ),
      steps: [for (final step in steps) _toStepCompanion(step, sessionId, now)],
      currentStepPosition: currentStepPosition,
      currentStepActiveSeconds: currentStepActiveSeconds,
      explicitlyAbandoned: explicitlyAbandoned,
    );
  }

  @override
  Future<void> saveCursor({
    required String userId,
    required String sessionId,
    required int currentStepPosition,
    required int activeSeconds,
  }) {
    final now = _clock().toUtc();
    return LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).savePlaybackCursor(
      sessionId: sessionId,
      currentStepPosition: currentStepPosition,
      activeSeconds: activeSeconds,
    );
  }

  @override
  Future<RoutineSessionSnapshot?> resumable({required String userId}) async {
    final session =
        await (_database.select(_database.localRoutineSessions)
              ..where(
                (r) => r.userId.equals(userId) & r.status.equals('in_progress'),
              )
              ..orderBy([(r) => OrderingTerm.desc(r.localUpdatedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (session == null) return null;
    return _snapshotFor(session);
  }

  @override
  Future<RoutineSessionSnapshot?> findById({
    required String userId,
    required String sessionId,
  }) async {
    final session =
        await (_database.select(_database.localRoutineSessions)
              ..where((r) => r.id.equals(sessionId) & r.userId.equals(userId)))
            .getSingleOrNull();
    if (session == null) return null;
    return _snapshotFor(session);
  }

  @override
  Future<void> expireInactiveSessions({required String userId}) {
    final now = _clock().toUtc();
    return LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).expireInactiveSessions();
  }

  Future<RoutineSessionSnapshot> _snapshotFor(
    LocalRoutineSession session,
  ) async {
    final steps =
        await (_database.select(_database.localSessionSteps)
              ..where((r) => r.sessionId.equals(session.id))
              ..orderBy([(r) => OrderingTerm.asc(r.positionSnapshot)]))
            .get();
    return RoutineSessionSnapshot(
      sessionId: session.id,
      routineId: session.routineId,
      routineVersion: session.routineVersion,
      recommendationId: session.recommendationId,
      source: session.source,
      startedAt: session.startedAt,
      status: session.status,
      currentStepPosition: session.currentStepPosition,
      currentStepActiveSeconds: session.currentStepActiveSeconds,
      steps: [
        for (final step in steps)
          RoutineStepSnapshot(
            stepId: step.routineStepId,
            exerciseId: step.exerciseIdSnapshot,
            position: step.positionSnapshot,
            status: step.status,
            targetDurationSeconds: step.targetDurationSeconds,
            activeDurationSeconds: step.activeDurationSeconds,
            skipRequested: step.skipRequested,
          ),
      ],
    );
  }

  LocalSessionStepsCompanion _toStepCompanion(
    RoutineStepSnapshot step,
    String sessionId,
    DateTime now,
  ) {
    final terminal = step.status != 'pending';
    final credited = step.activeDurationSeconds;
    return LocalSessionStepsCompanion.insert(
      sessionId: sessionId,
      routineStepId: step.stepId,
      exerciseIdSnapshot: step.exerciseId,
      positionSnapshot: step.position,
      status: step.status,
      targetDurationSeconds: step.targetDurationSeconds,
      activeDurationSeconds: Value(credited),
      skipRequested: Value(step.skipRequested),
      startedAt: (terminal && credited > 0) ? Value(now) : const Value(null),
      finishedAt: terminal ? Value(now) : const Value(null),
      localUpdatedAt: now,
    );
  }
}
