import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/sync/domain/sync_operation.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';

/// Fixed remote (server) UUIDs used to seed the mapping boundary in tests.
const routineUuid = '00000000-0000-4000-8000-000000000101';
const exerciseUuid = '00000000-0000-4000-8000-000000000102';
const goalUuid = '00000000-0000-4000-8000-000000000103';
const shouldersUuid = '00000000-0000-4000-8000-000000000104';

/// A controllable in-memory [SyncTransport]. Records every pushed operation in
/// [pushed] so tests can assert ordering and idempotent acknowledgement.
class FakeSyncTransport implements SyncTransport {
  FakeSyncTransport({this.onPush, this.onPull});

  final Future<SyncPushResponse> Function(SyncOperation op)? onPush;
  final Future<SyncPullResponse> Function(int afterCursor)? onPull;
  final List<SyncOperation> pushed = [];

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async {
    pushed.add(operation);
    final handler = onPush;
    if (handler != null) return handler(operation);
    return const SyncAccepted();
  }

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async {
    final handler = onPull;
    if (handler != null) return handler(afterCursor);
    return SyncPullSuccess(changes: const [], cursor: afterCursor);
  }
}

/// A transport whose push always throws, used to prove the engine converts
/// unexpected transport errors into retryable failures.
class ThrowingSyncTransport implements SyncTransport {
  const ThrowingSyncTransport();

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async {
    throw StateError('boom');
  }

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async {
    throw StateError('boom');
  }
}

/// A transport that reports every push/pull as unavailable (unconfigured or
/// unauthenticated) while retaining the outbox without consuming budget.
class UnavailableSyncTransport implements SyncTransport {
  const UnavailableSyncTransport();

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async =>
      const SyncUnavailable();

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async => const SyncPullUnavailable();
}

/// A mutable clock for deterministic, time-controlled tests.
class MutableClock {
  MutableClock(this.value);
  DateTime value;
  DateTime call() => value;
}

/// Seeds the minimal content + identity rows required for user-data writes,
/// plus the remote-id mapping boundary used to resolve wire UUIDs.
Future<void> seedSyncCatalog(AppDatabase db, DateTime now) async {
  await db
      .into(db.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'ease_stiffness', kind: 'goal'),
      );
  await db
      .into(db.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'shoulders', kind: 'body_area'),
      );
  await db
      .into(db.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: 'exercise-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: now,
        ),
      );
  await db
      .into(db.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 60,
          version: 1,
          updatedAt: now,
        ),
      );
  await db
      .into(db.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step-1',
          routineId: 'routine-1',
          exerciseId: 'exercise-1',
          position: 1,
          durationSeconds: 60,
        ),
      );
  await db
      .into(db.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
  await seedIdMappings(db);
}

/// Seeds the explicit local-id -> server-UUID mapping boundary.
Future<void> seedIdMappings(AppDatabase db) {
  final store = LocalIdMappingStore(db);
  return Future.wait([
    store.store(
      kind: RemoteIdMappingKind.routine,
      localId: 'routine-1',
      remoteId: routineUuid,
    ),
    store.store(
      kind: RemoteIdMappingKind.exercise,
      localId: 'exercise-1',
      remoteId: exerciseUuid,
    ),
    store.store(
      kind: RemoteIdMappingKind.taxonomy,
      localId: 'ease_stiffness',
      remoteId: goalUuid,
    ),
    store.store(
      kind: RemoteIdMappingKind.taxonomy,
      localId: 'shoulders',
      remoteId: shouldersUuid,
    ),
  ]);
}

/// A [LocalUserDataRepository] bound to `user-1` at [now].
LocalUserDataRepository userData(
  AppDatabase db,
  DateTime now, {
  String Function()? operationIdGenerator,
}) => LocalUserDataRepository(
  db,
  activeUserId: 'user-1',
  clock: () => now,
  operationIdGenerator: operationIdGenerator,
);

LocalCheckInsCompanion checkIn(String id, DateTime now) =>
    LocalCheckInsCompanion.insert(
      id: id,
      userId: 'user-1',
      bodyState: 'stiff',
      goalKey: 'ease_stiffness',
      availableMinutes: 5,
      startedAt: now,
      localUpdatedAt: now,
    );

LocalRecommendationsCompanion recommendation(
  String id,
  String checkInId,
  DateTime now,
) => LocalRecommendationsCompanion.insert(
  id: id,
  userId: 'user-1',
  checkInId: checkInId,
  routineId: 'routine-1',
  engineVersion: 'rules_v1',
  rank: 0,
  score: 1,
  reasonCodesJson: '[]',
  shownAt: now,
  localUpdatedAt: now,
);

LocalRoutineSessionsCompanion session(
  String id,
  DateTime now, {
  String routineId = 'routine-1',
}) => LocalRoutineSessionsCompanion.insert(
  id: id,
  userId: 'user-1',
  routineId: routineId,
  routineVersion: 1,
  status: 'in_progress',
  startedAt: now,
  targetDurationSeconds: 60,
  actualDurationSeconds: 0,
  totalSteps: 1,
  completionPolicyVersion: 'raha_001_v1',
  source: 'recommendation',
  localUpdatedAt: now,
);

/// A fully credited step that makes its single-step session `completed`.
LocalSessionStepsCompanion completedStep(String sessionId, DateTime now) =>
    LocalSessionStepsCompanion.insert(
      sessionId: sessionId,
      routineStepId: 'step-1',
      exerciseIdSnapshot: 'exercise-1',
      positionSnapshot: 1,
      status: 'completed',
      targetDurationSeconds: 60,
      activeDurationSeconds: const Value(60),
      startedAt: Value(now),
      finishedAt: Value(now),
      localUpdatedAt: now,
    );

LocalSessionFeedbackCompanion feedback(String sessionId, DateTime now) =>
    LocalSessionFeedbackCompanion.insert(
      sessionId: sessionId,
      userId: 'user-1',
      rating: 'little_better',
      createdAt: now,
      localUpdatedAt: now,
    );

LocalSavedRoutinesCompanion savedRoutine(String routineId, DateTime now) =>
    LocalSavedRoutinesCompanion.insert(
      userId: 'user-1',
      routineId: routineId,
      savedAt: now,
      localUpdatedAt: now,
    );

LocalUserPreferencesCompanion preferences(DateTime now) =>
    LocalUserPreferencesCompanion.insert(
      userId: 'user-1',
      experienceLevel: 'beginner',
      localUpdatedAt: now,
    );
