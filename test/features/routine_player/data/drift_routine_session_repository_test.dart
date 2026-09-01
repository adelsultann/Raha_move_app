import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';
import 'package:raha_move/features/routine_player/data/drift_routine_session_repository.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 29, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  DriftRoutineSessionRepository repository() =>
      DriftRoutineSessionRepository(database, clock: () => now);

  List<RoutineStepSnapshot> twoPendingSteps() => const [
    RoutineStepSnapshot(
      stepId: 'step-1',
      exerciseId: 'exercise-1',
      position: 1,
      status: 'pending',
      targetDurationSeconds: 20,
      activeDurationSeconds: 0,
      skipRequested: false,
    ),
    RoutineStepSnapshot(
      stepId: 'step-2',
      exerciseId: 'exercise-1',
      position: 2,
      status: 'pending',
      targetDurationSeconds: 40,
      activeDurationSeconds: 0,
      skipRequested: false,
    ),
  ];

  test(
    'start creates exactly one session with version, link, time, and cursor',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        recommendationId: 'rec-1',
        startedAt: now,
        steps: twoPendingSteps(),
        currentStepPosition: 1,
        currentStepActiveSeconds: 0,
      );

      final sessions = await database
          .select(database.localRoutineSessions)
          .get();
      expect(sessions, hasLength(1));
      final session = sessions.single;
      expect(session.id, 'session-1');
      expect(session.routineId, 'routine-1');
      expect(session.routineVersion, 1);
      expect(session.recommendationId, 'rec-1');
      expect(
        session.startedAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(session.status, 'in_progress');
      expect(session.currentStepPosition, 1);
      expect(session.currentStepActiveSeconds, 0);

      final steps = await database.select(database.localSessionSteps).get();
      expect(steps, hasLength(2));
      expect(steps.every((s) => s.status == 'pending'), isTrue);
      expect(steps.every((s) => s.activeDurationSeconds == 0), isTrue);
    },
  );

  test(
    'saveCursor advances the cursor locally without terminalizing or syncing',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: twoPendingSteps(),
        currentStepPosition: 1,
        currentStepActiveSeconds: 0,
      );
      final before = await database.select(database.syncOutbox).get();

      await repository().saveCursor(
        userId: 'user-1',
        sessionId: 'session-1',
        currentStepPosition: 1,
        activeSeconds: 15,
      );

      final snapshot = await repository().resumable(userId: 'user-1');
      expect(snapshot, isNotNull);
      expect(snapshot!.currentStepPosition, 1);
      expect(snapshot.currentStepActiveSeconds, 15);
      expect(snapshot.steps.first.status, 'pending');
      expect(snapshot.steps.first.activeDurationSeconds, 0);

      // Cursor ticks are local-only: no additional outbox rows are enqueued.
      final after = await database.select(database.syncOutbox).get();
      expect(after.length, before.length);
    },
  );

  test(
    'resumable returns the snapshot and findById maps a specific session',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: twoPendingSteps(),
        currentStepPosition: 2,
        currentStepActiveSeconds: 10,
      );

      final resumable = await repository().resumable(userId: 'user-1');
      expect(resumable?.sessionId, 'session-1');
      expect(resumable?.routineId, 'routine-1');
      expect(resumable?.currentStepPosition, 2);
      expect(resumable?.currentStepActiveSeconds, 10);
      expect(resumable?.steps, hasLength(2));

      final byId = await repository().findById(
        userId: 'user-1',
        sessionId: 'session-1',
      );
      expect(byId?.sessionId, 'session-1');
      expect(
        await repository().findById(userId: 'user-2', sessionId: 'session-1'),
        isNull,
      );
    },
  );

  test(
    'terminal qualifying save marks completed and clears the cursor',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: twoPendingSteps(),
        currentStepPosition: 1,
        currentStepActiveSeconds: 10,
      );

      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: const [
          RoutineStepSnapshot(
            stepId: 'step-1',
            exerciseId: 'exercise-1',
            position: 1,
            status: 'completed',
            targetDurationSeconds: 20,
            activeDurationSeconds: 20,
            skipRequested: false,
          ),
          RoutineStepSnapshot(
            stepId: 'step-2',
            exerciseId: 'exercise-1',
            position: 2,
            status: 'completed',
            targetDurationSeconds: 40,
            activeDurationSeconds: 40,
            skipRequested: false,
          ),
        ],
      );

      final session = await (database.select(
        database.localRoutineSessions,
      )..where((r) => r.id.equals('session-1'))).getSingle();
      expect(session.status, 'completed');
      expect(session.currentStepPosition, isNull);
      expect(session.currentStepActiveSeconds, isNull);
    },
  );

  test(
    'terminal non-qualifying save marks abandoned (no completion)',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: twoPendingSteps(),
        currentStepPosition: 1,
        currentStepActiveSeconds: 0,
      );

      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: const [
          RoutineStepSnapshot(
            stepId: 'step-1',
            exerciseId: 'exercise-1',
            position: 1,
            status: 'completed',
            targetDurationSeconds: 20,
            activeDurationSeconds: 20,
            skipRequested: false,
          ),
          RoutineStepSnapshot(
            stepId: 'step-2',
            exerciseId: 'exercise-1',
            position: 2,
            status: 'skipped',
            targetDurationSeconds: 40,
            activeDurationSeconds: 0,
            skipRequested: true,
          ),
        ],
      );

      final session = await (database.select(
        database.localRoutineSessions,
      )..where((r) => r.id.equals('session-1'))).getSingle();
      expect(session.status, 'abandoned');
      expect(session.currentStepPosition, isNull);
    },
  );

  test(
    'explicit abandonment overrides a threshold-qualified session',
    () async {
      final repo = repository();
      const qualifying = [
        RoutineStepSnapshot(
          stepId: 'step-1',
          exerciseId: 'exercise-1',
          position: 1,
          status: 'completed',
          targetDurationSeconds: 20,
          activeDurationSeconds: 20,
          skipRequested: false,
        ),
        RoutineStepSnapshot(
          stepId: 'step-2',
          exerciseId: 'exercise-1',
          position: 2,
          status: 'completed',
          targetDurationSeconds: 40,
          activeDurationSeconds: 40,
          skipRequested: false,
        ),
      ];

      // The same fully-credited steps qualify for `completed` by default...
      await repo.save(
        userId: 'user-1',
        sessionId: 'qualified',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: qualifying,
      );
      final qualified = await (database.select(
        database.localRoutineSessions,
      )..where((r) => r.id.equals('qualified'))).getSingle();
      expect(qualified.status, 'completed');

      // ...but an explicit abandonment persists `abandoned` regardless.
      await repo.save(
        userId: 'user-1',
        sessionId: 'qualified-abandoned',
        routineId: 'routine-1',
        routineVersion: 1,
        startedAt: now,
        steps: qualifying,
        explicitlyAbandoned: true,
      );
      final abandoned = await (database.select(
        database.localRoutineSessions,
      )..where((r) => r.id.equals('qualified-abandoned'))).getSingle();
      expect(abandoned.status, 'abandoned');
      expect(abandoned.currentStepPosition, isNull);
      expect(abandoned.currentStepActiveSeconds, isNull);
    },
  );

  test('re-saving the same terminal state is idempotent', () async {
    final repo = repository();
    const completed = [
      RoutineStepSnapshot(
        stepId: 'step-1',
        exerciseId: 'exercise-1',
        position: 1,
        status: 'completed',
        targetDurationSeconds: 20,
        activeDurationSeconds: 20,
        skipRequested: false,
      ),
      RoutineStepSnapshot(
        stepId: 'step-2',
        exerciseId: 'exercise-1',
        position: 2,
        status: 'completed',
        targetDurationSeconds: 40,
        activeDurationSeconds: 40,
        skipRequested: false,
      ),
    ];
    Future<void> terminalize() => repo.save(
      userId: 'user-1',
      sessionId: 'session-1',
      routineId: 'routine-1',
      routineVersion: 1,
      startedAt: now,
      steps: completed,
    );

    await terminalize();
    await terminalize();

    final sessions = await database.select(database.localRoutineSessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.status, 'completed');
    // One finalize op per terminal session; a retry does not duplicate.
    final finalizeOps = await (database.select(
      database.syncOutbox,
    )..where((r) => r.kind.equals('session_finalize'))).get();
    expect(finalizeOps, hasLength(1));
  });

  test(
    'expireInactiveSessions abandons a stale session (injected clock)',
    () async {
      final staleStartedAt = now.subtract(const Duration(hours: 25));
      await database
          .into(database.localRoutineSessions)
          .insert(
            LocalRoutineSessionsCompanion.insert(
              id: 'stale',
              userId: 'user-1',
              routineId: 'routine-1',
              routineVersion: 1,
              status: 'in_progress',
              startedAt: staleStartedAt,
              targetDurationSeconds: 60,
              actualDurationSeconds: 0,
              totalSteps: 2,
              completionPolicyVersion: kRoutineCompletionPolicyVersion,
              source: 'recommendation',
              localUpdatedAt: staleStartedAt,
            ),
          );
      await database
          .into(database.localSessionSteps)
          .insert(
            LocalSessionStepsCompanion.insert(
              sessionId: 'stale',
              routineStepId: 'step-1',
              exerciseIdSnapshot: 'exercise-1',
              positionSnapshot: 1,
              status: 'pending',
              targetDurationSeconds: 20,
              localUpdatedAt: staleStartedAt,
            ),
          );
      await database
          .into(database.localSessionSteps)
          .insert(
            LocalSessionStepsCompanion.insert(
              sessionId: 'stale',
              routineStepId: 'step-2',
              exerciseIdSnapshot: 'exercise-1',
              positionSnapshot: 2,
              status: 'pending',
              targetDurationSeconds: 40,
              localUpdatedAt: staleStartedAt,
            ),
          );

      await repository().expireInactiveSessions(userId: 'user-1');

      expect(await repository().resumable(userId: 'user-1'), isNull);
      final row = await (database.select(
        database.localRoutineSessions,
      )..where((r) => r.id.equals('stale'))).getSingle();
      expect(row.status, 'abandoned');
    },
  );
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'ease_stiffness', kind: 'goal'),
      );
  await database
      .into(database.localExercises)
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
  await database
      .into(database.localRoutines)
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
  await database
      .into(database.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step-1',
          routineId: 'routine-1',
          exerciseId: 'exercise-1',
          position: 1,
          durationSeconds: 20,
        ),
      );
  await database
      .into(database.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step-2',
          routineId: 'routine-1',
          exerciseId: 'exercise-1',
          position: 2,
          durationSeconds: 40,
        ),
      );
  await database
      .into(database.localCheckIns)
      .insert(
        LocalCheckInsCompanion.insert(
          id: 'check-in-1',
          userId: 'user-1',
          bodyState: 'stiff',
          goalKey: 'ease_stiffness',
          availableMinutes: 5,
          startedAt: now,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localRecommendations)
      .insert(
        LocalRecommendationsCompanion.insert(
          id: 'rec-1',
          userId: 'user-1',
          checkInId: 'check-in-1',
          routineId: 'routine-1',
          engineVersion: 'rules_v1',
          rank: 0,
          score: 1,
          reasonCodesJson: '[]',
          shownAt: now,
          localUpdatedAt: now,
        ),
      );
  final store = LocalIdMappingStore(database);
  await store.store(
    kind: RemoteIdMappingKind.routine,
    localId: 'routine-1',
    remoteId: '00000000-0000-4000-8000-000000000101',
  );
  await store.store(
    kind: RemoteIdMappingKind.exercise,
    localId: 'exercise-1',
    remoteId: '00000000-0000-4000-8000-000000000102',
  );
}
