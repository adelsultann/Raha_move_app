import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 29, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seedCatalog(database, now);
  });

  tearDown(() => database.close());

  test(
    'enforces catalog relationships, valid check-in duration, and step order',
    () async {
      await expectLater(
        database
            .into(database.localRoutineSteps)
            .insert(
              LocalRoutineStepsCompanion.insert(
                id: 'step-two',
                routineId: 'routine-1',
                exerciseId: 'exercise-1',
                position: 1,
                durationSeconds: 20,
              ),
            ),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        database
            .into(database.localCheckIns)
            .insert(
              LocalCheckInsCompanion.insert(
                id: 'invalid-check-in',
                userId: 'user-1',
                bodyState: 'stiff',
                goalKey: 'ease_stiffness',
                availableMinutes: 7,
                startedAt: now,
                localUpdatedAt: now,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'saves a check-in and durable outbox operation atomically and locally',
    () async {
      final repository = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );
      await repository.saveCheckIn(
        checkIn: LocalCheckInsCompanion.insert(
          id: 'check-in-1',
          userId: 'user-1',
          bodyState: 'stiff',
          goalKey: 'ease_stiffness',
          availableMinutes: 5,
          startedAt: now,
          localUpdatedAt: now,
        ),
        bodyAreaKeys: const ['shoulders'],
      );

      final checkIn = await (database.select(
        database.localCheckIns,
      )..where((row) => row.id.equals('check-in-1'))).getSingle();
      final areas = await database.select(database.localCheckInBodyAreas).get();
      final outbox = await database.select(database.syncOutbox).getSingle();

      expect(checkIn.syncState, SyncState.pendingCreate);
      expect(areas.single.bodyAreaKey, 'shoulders');
      expect(outbox.entityId, 'check-in-1');
      expect(jsonDecode(outbox.payloadJson), {
        'v': 1,
        'id': 'check-in-1',
        'bodyState': 'stiff',
        'goalKey': 'ease_stiffness',
        'availableMinutes': 5,
        'bodyAreaKeys': ['shoulders'],
      });
    },
  );

  test(
    'replaces preferred media without changing the stable exercise identity',
    () async {
      await database
          .into(database.localMediaAssets)
          .insert(
            LocalMediaAssetsCompanion.insert(
              id: 'media-2',
              exerciseId: 'exercise-1',
              mediaType: 'video',
              storageKey: 'delivery/exercise-1/v2.mp4',
              mimeType: 'video/mp4',
              checksumSha256: 'b' * 64,
              status: 'published',
              updatedAt: now,
            ),
          );

      final repository = LocalContentRepository(database);
      final localRoutines = await repository.watchPublishedRoutines().first;
      await repository.replacePreferredMedia(
        exerciseId: 'exercise-1',
        replacementMediaId: 'media-2',
      );

      final exercise = await (database.select(
        database.localExercises,
      )..where((row) => row.id.equals('exercise-1'))).getSingle();
      final preferred = await repository.findPreferredPlayableMedia(
        'exercise-1',
      );

      expect(exercise.id, 'exercise-1');
      expect(preferred?.id, 'media-2');
      expect(localRoutines.single.id, 'routine-1');
    },
  );

  test('rejects a second preferred published media asset on UPDATE', () async {
    await database
        .into(database.localMediaAssets)
        .insert(
          LocalMediaAssetsCompanion.insert(
            id: 'media-2',
            exerciseId: 'exercise-1',
            mediaType: 'video',
            storageKey: 'delivery/exercise-1/v2.mp4',
            mimeType: 'video/mp4',
            checksumSha256: 'b' * 64,
            status: 'published',
            updatedAt: now,
          ),
        );

    await expectLater(
      (database.update(database.localMediaAssets)
            ..where((row) => row.id.equals('media-2')))
          .write(const LocalMediaAssetsCompanion(isPreferred: Value(true))),
      throwsA(isA<Exception>()),
    );
  });

  test('synced edit becomes pending update and clears diagnostics', () async {
    await database
        .into(database.localCheckIns)
        .insert(
          LocalCheckInsCompanion.insert(
            id: 'synced-check-in',
            userId: 'user-1',
            bodyState: 'stiff',
            goalKey: 'ease_stiffness',
            availableMinutes: 5,
            startedAt: now,
            localUpdatedAt: now,
            syncState: const Value(SyncState.synced),
            lastSyncError: const Value(SyncDiagnosticCode.retryExhausted),
          ),
        );
    final repository = LocalUserDataRepository(
      database,
      activeUserId: 'user-1',
      clock: () => now.add(const Duration(minutes: 1)),
    );
    await repository.saveCheckIn(
      checkIn: LocalCheckInsCompanion.insert(
        id: 'synced-check-in',
        userId: 'user-1',
        bodyState: 'tense',
        goalKey: 'ease_stiffness',
        availableMinutes: 5,
        startedAt: now,
        localUpdatedAt: now,
      ),
      bodyAreaKeys: const ['shoulders'],
    );
    final row = await (database.select(
      database.localCheckIns,
    )..where((r) => r.id.equals('synced-check-in'))).getSingle();
    expect(row.syncState, SyncState.pendingUpdate);
    expect(row.lastSyncError, isNull);
  });

  test('save then unsave coalesces to one owner-scoped tombstone', () async {
    final repository = LocalUserDataRepository(
      database,
      activeUserId: 'user-1',
      clock: () => now,
    );
    await repository.saveSavedRoutine(
      savedRoutine: LocalSavedRoutinesCompanion.insert(
        userId: 'user-1',
        routineId: 'routine-1',
        savedAt: now,
        localUpdatedAt: now,
      ),
    );
    await repository.saveSavedRoutine(
      savedRoutine: LocalSavedRoutinesCompanion.insert(
        userId: 'user-1',
        routineId: 'routine-1',
        savedAt: now,
        deletedAt: Value(now),
        localUpdatedAt: now,
      ),
    );
    final outbox = await repository.dueOutbox();
    expect(outbox, hasLength(1));
    expect(outbox.single.operation, OutboxOperation.delete);
    expect(outbox.single.ownerUserId, 'user-1');
  });

  test(
    'rejects cross-account writes and purges only active private data',
    () async {
      await database
          .into(database.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              userId: 'user-2',
              preferredLocale: 'en',
              timezone: 'Asia/Riyadh',
              weeklyGoalDays: 3,
              localUpdatedAt: now,
            ),
          );
      final first = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );
      final second = LocalUserDataRepository(
        database,
        activeUserId: 'user-2',
        clock: () => now,
      );
      await expectLater(
        first.saveCheckIn(
          checkIn: LocalCheckInsCompanion.insert(
            id: 'wrong-owner',
            userId: 'user-2',
            bodyState: 'stiff',
            goalKey: 'ease_stiffness',
            availableMinutes: 5,
            startedAt: now,
            localUpdatedAt: now,
          ),
          bodyAreaKeys: const ['shoulders'],
        ),
        throwsStateError,
      );
      await second.purgeActiveUser();
      expect(
        await (database.select(
          database.localProfiles,
        )..where((r) => r.userId.equals('user-1'))).getSingleOrNull(),
        isNotNull,
      );
    },
  );

  test(
    'rolls back the domain row when its outbox transaction cannot complete',
    () async {
      final repository = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );

      await expectLater(
        repository.saveCheckIn(
          checkIn: LocalCheckInsCompanion.insert(
            id: 'rolled-back-check-in',
            userId: 'user-1',
            bodyState: 'stiff',
            goalKey: 'ease_stiffness',
            availableMinutes: 5,
            startedAt: now,
            localUpdatedAt: now,
          ),
          bodyAreaKeys: const ['unknown-area'],
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        await (database.select(database.localCheckIns)
              ..where((row) => row.id.equals('rolled-back-check-in')))
            .getSingleOrNull(),
        isNull,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    },
  );

  test(
    'migrates v1 history to the current schema and remains usable',
    () async {
      await database.close();
      final executor = NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE environment_entries (key TEXT NOT NULL PRIMARY KEY, '
            'value TEXT NOT NULL)',
          );
          raw.execute(
            "INSERT INTO environment_entries VALUES ('locale', 'ar')",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      );
      final migrated = AppDatabase(executor);

      final legacy = await migrated
          .select(migrated.environmentEntries)
          .getSingle();

      expect(legacy.key, 'locale');
      expect(legacy.value, 'ar');
      await _seedCatalog(migrated, now);
      final repository = LocalUserDataRepository(
        migrated,
        activeUserId: 'user-1',
        clock: () => now,
      );
      await repository.saveCheckIn(
        checkIn: LocalCheckInsCompanion.insert(
          id: 'migrated-check-in',
          userId: 'user-1',
          bodyState: 'stiff',
          goalKey: 'ease_stiffness',
          availableMinutes: 5,
          startedAt: now,
          localUpdatedAt: now,
        ),
        bodyAreaKeys: const ['shoulders'],
      );
      expect(await repository.dueOutbox(), hasLength(1));
      await migrated.close();
    },
  );

  test('migrates durable v2 session, step, and outbox history to v3', () async {
    await database.close();
    final migrated = AppDatabase(_v2FixtureExecutor(now));

    final session = await (migrated.select(
      migrated.localRoutineSessions,
    )..where((row) => row.id.equals('v2-session'))).getSingle();
    final step = await (migrated.select(
      migrated.localSessionSteps,
    )..where((row) => row.sessionId.equals('v2-session'))).getSingle();
    final outbox = await (migrated.select(
      migrated.syncOutbox,
    )..where((row) => row.entityId.equals('v2-session'))).getSingle();

    expect(session.targetDurationSeconds, 60);
    expect(session.totalSteps, 1);
    expect(session.actualDurationSeconds, 48);
    expect(step.activeDurationSeconds, 48);
    expect(step.status, 'partial');
    expect(outbox.payloadJson, contains('v2-session'));

    await migrated
        .into(migrated.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            entityType: 'routine_session',
            entityId: 'v3-write',
            ownerUserId: 'user-1',
            operation: OutboxOperation.upsert,
            payloadJson: '{"v":1}',
            nextAttemptAt: now,
            createdAt: now,
          ),
        );
    expect(await migrated.select(migrated.syncOutbox).get(), hasLength(2));
    await migrated.close();
  });

  test(
    'preferences and reminder writes are local-first and owner scoped',
    () async {
      final repository = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );
      await repository.savePreferences(
        preferences: LocalUserPreferencesCompanion.insert(
          userId: 'user-1',
          experienceLevel: 'beginner',
          localUpdatedAt: now,
        ),
      );
      await repository.saveReminder(
        reminder: LocalReminderSchedulesCompanion.insert(
          id: 'reminder-1',
          userId: 'user-1',
          localTime: '08:00',
          daysOfWeekJson: '[1,2]',
          timezone: 'Asia/Riyadh',
          localUpdatedAt: now,
        ),
      );
      expect(
        (await repository.dueOutbox()).map((row) => row.entityType),
        containsAll(['user_preferences', 'reminder_schedule']),
      );
      await expectLater(
        repository.saveReminder(
          reminder: LocalReminderSchedulesCompanion.insert(
            id: 'wrong-reminder',
            userId: 'other',
            localTime: '08:00',
            daysOfWeekJson: '[]',
            timezone: 'Asia/Riyadh',
            localUpdatedAt: now,
          ),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'rejects cross-owner check-in, recommendation, and reminder ID collisions',
    () async {
      await _seedSecondUser(database, now);
      final first = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );
      final second = LocalUserDataRepository(
        database,
        activeUserId: 'user-2',
        clock: () => now,
      );
      await first.saveCheckIn(
        checkIn: _checkIn(id: 'shared-check-in', userId: 'user-1', now: now),
        bodyAreaKeys: const ['shoulders'],
      );
      await expectLater(
        second.saveCheckIn(
          checkIn: _checkIn(id: 'shared-check-in', userId: 'user-2', now: now),
          bodyAreaKeys: const ['shoulders'],
        ),
        throwsStateError,
      );
      await second.saveCheckIn(
        checkIn: _checkIn(id: 'user-2-check-in', userId: 'user-2', now: now),
        bodyAreaKeys: const ['shoulders'],
      );
      await first.saveRecommendation(
        recommendation: _recommendation(
          id: 'shared-recommendation',
          userId: 'user-1',
          checkInId: 'shared-check-in',
          now: now,
        ),
      );
      await expectLater(
        second.saveRecommendation(
          recommendation: _recommendation(
            id: 'shared-recommendation',
            userId: 'user-2',
            checkInId: 'user-2-check-in',
            now: now,
          ),
        ),
        throwsStateError,
      );
      await first.saveReminder(reminder: _reminder('user-1', now));
      await expectLater(
        second.saveReminder(reminder: _reminder('user-2', now)),
        throwsStateError,
      );
    },
  );

  test('session snapshots must exactly match the canonical routine', () async {
    final repository = LocalUserDataRepository(
      database,
      activeUserId: 'user-1',
      clock: () => now,
    );
    await expectLater(
      repository.saveSessionWithSteps(
        session: _session(now, target: 59),
        steps: [_sessionStep('partial', 48, now)],
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.saveSessionWithSteps(
        session: _session(now, version: 2),
        steps: [_sessionStep('partial', 48, now)],
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.saveSessionWithSteps(
        session: _session(now, totalSteps: 0),
        steps: [_sessionStep('partial', 48, now)],
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.saveSessionWithSteps(
        session: _session(now, target: 0),
        steps: [_sessionStep('partial', 0, now)],
      ),
      throwsArgumentError,
    );
  });

  test(
    'canonicalizes credited skips and rejects invalid RAHA-001 step states',
    () async {
      final repository = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: () => now,
      );
      await repository.saveSessionWithSteps(
        session: _session(now, id: 'credited-skip'),
        steps: [_sessionStep('skipped', 1, now, sessionId: 'credited-skip')],
      );
      final canonicalized = await (database.select(
        database.localSessionSteps,
      )..where((row) => row.sessionId.equals('credited-skip'))).getSingle();
      expect(canonicalized.status, 'partial');
      expect(canonicalized.skipRequested, isTrue);

      await repository.saveSessionWithSteps(
        session: _session(now, id: 'full-step'),
        steps: [_sessionStep('completed', 60, now, sessionId: 'full-step')],
      );
      expect(
        (await (database.select(
          database.localRoutineSessions,
        )..where((row) => row.id.equals('full-step'))).getSingle()).status,
        'completed',
      );

      for (final invalid in [
        _sessionStep('completed', 59, now, sessionId: 'bad-completed'),
        _sessionStep('partial', 0, now, sessionId: 'bad-partial-zero'),
        _sessionStep('partial', 60, now, sessionId: 'bad-partial-full'),
        _sessionStep('pending', 1, now, sessionId: 'bad-pending-credit'),
        _sessionStep(
          'pending',
          0,
          now,
          sessionId: 'bad-pending-finished',
        ).copyWith(finishedAt: Value(now)),
        _sessionStep(
          'skipped',
          0,
          now,
          sessionId: 'bad-skip-started',
        ).copyWith(startedAt: Value(now)),
      ]) {
        await expectLater(
          repository.saveSessionWithSteps(
            session: _session(now, id: invalid.sessionId.value),
            steps: [invalid],
          ),
          throwsArgumentError,
        );
      }
    },
  );

  test('completion requires exactly 80% credited duration and floor skip allowance', () async {
    await _seedFiveStepRoutine(database, now);
    final repository = LocalUserDataRepository(
      database,
      activeUserId: 'user-1',
      clock: () => now,
    );
    await repository.saveSessionWithSteps(
      session: _session(
        now,
        id: 'qualified',
        routineId: 'routine-5',
        target: 100,
        totalSteps: 5,
      ),
      steps: [
        for (var i = 1; i <= 4; i++)
          _sessionStep(
            'completed',
            20,
            now,
            id: 'routine-5-step-$i',
            sessionId: 'qualified',
            position: i,
            target: 20,
          ),
        _sessionStep(
          'skipped',
          0,
          now,
          id: 'routine-5-step-5',
          sessionId: 'qualified',
          position: 5,
          target: 20,
        ),
      ],
    );
    final qualified = await (database.select(
      database.localRoutineSessions,
    )..where((row) => row.id.equals('qualified'))).getSingle();
    expect(qualified.status, 'completed');

    await repository.saveSessionWithSteps(
      session: _session(
        now,
        id: 'too-many-skips',
        routineId: 'routine-5',
        target: 100,
        totalSteps: 5,
      ),
      steps: [
        for (var i = 1; i <= 3; i++)
          _sessionStep(
            'completed',
            20,
            now,
            id: 'routine-5-step-$i',
            sessionId: 'too-many-skips',
            position: i,
            target: 20,
          ),
        for (var i = 4; i <= 5; i++)
          _sessionStep(
            'skipped',
            0,
            now,
            id: 'routine-5-step-$i',
            sessionId: 'too-many-skips',
            position: i,
            target: 20,
          ),
      ],
    );
    final abandoned = await (database.select(
      database.localRoutineSessions,
    )..where((row) => row.id.equals('too-many-skips'))).getSingle();
    expect(abandoned.status, 'abandoned');
    await repository.saveSessionWithSteps(
      session: _session(now, id: 'under-80'),
      steps: [_sessionStep('partial', 47, now, sessionId: 'under-80')],
    );
    expect(
      (await (database.select(
        database.localRoutineSessions,
      )..where((row) => row.id.equals('under-80'))).getSingle()).status,
      'abandoned',
    );
  });

  test('terminal sessions are idempotent and cannot regress', () async {
    final repository = LocalUserDataRepository(
      database,
      activeUserId: 'user-1',
      clock: () => now,
    );
    final session = _session(now);
    final steps = [_sessionStep('partial', 48, now)];
    await repository.saveSessionWithSteps(session: session, steps: steps);
    await repository.saveSessionWithSteps(session: session, steps: steps);
    expect(await repository.dueOutbox(), hasLength(1));
    await expectLater(
      repository.saveSessionWithSteps(
        session: session,
        steps: [_sessionStep('pending', 0, now)],
      ),
      throwsStateError,
    );
    await expectLater(
      repository.saveSessionWithSteps(
        session: session,
        steps: [_sessionStep('partial', 47, now)],
      ),
      throwsStateError,
    );
  });

  test(
    'session expiry uses last credited activity, not metadata activity',
    () async {
      final clock = _MutableClock(now);
      final repository = LocalUserDataRepository(
        database,
        activeUserId: 'user-1',
        clock: clock.call,
      );
      await database
          .into(database.localRoutineSessions)
          .insert(
            _session(
              now.subtract(const Duration(hours: 30)),
              id: 'expired',
            ).copyWith(localUpdatedAt: Value(now)),
          );
      await database
          .into(database.localSessionSteps)
          .insert(
            _sessionStep(
              'partial',
              1,
              now.subtract(const Duration(hours: 25)),
              sessionId: 'expired',
            ),
          );
      await repository.expireInactiveSessions();
      final expired = await (database.select(
        database.localRoutineSessions,
      )..where((row) => row.id.equals('expired'))).getSingle();
      expect(expired.status, 'abandoned');
      await repository.expireInactiveSessions();
      expect(await repository.dueOutbox(), hasLength(1));
    },
  );
}

Future<void> _seedCatalog(AppDatabase database, DateTime now) async {
  await database
      .into(database.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'ease_stiffness', kind: 'goal'),
      );
  await database
      .into(database.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'shoulders', kind: 'body_area'),
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
          durationSeconds: 60,
        ),
      );
  await database
      .into(database.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: 'media-1',
          exerciseId: 'exercise-1',
          mediaType: 'video',
          storageKey: 'delivery/exercise-1/v1.mp4',
          mimeType: 'video/mp4',
          checksumSha256: 'a' * 64,
          status: 'published',
          isPreferred: const Value(true),
          updatedAt: now,
        ),
      );
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
}

Future<void> _seedSecondUser(AppDatabase database, DateTime now) => database
    .into(database.localProfiles)
    .insert(
      LocalProfilesCompanion.insert(
        userId: 'user-2',
        preferredLocale: 'en',
        timezone: 'Asia/Riyadh',
        weeklyGoalDays: 3,
        localUpdatedAt: now,
      ),
    );

LocalCheckInsCompanion _checkIn({
  required String id,
  required String userId,
  required DateTime now,
}) => LocalCheckInsCompanion.insert(
  id: id,
  userId: userId,
  bodyState: 'stiff',
  goalKey: 'ease_stiffness',
  availableMinutes: 5,
  startedAt: now,
  localUpdatedAt: now,
);

LocalRecommendationsCompanion _recommendation({
  required String id,
  required String userId,
  required String checkInId,
  required DateTime now,
}) => LocalRecommendationsCompanion.insert(
  id: id,
  userId: userId,
  checkInId: checkInId,
  routineId: 'routine-1',
  engineVersion: 'rules_v1',
  rank: 0,
  score: 1,
  reasonCodesJson: '[]',
  shownAt: now,
  localUpdatedAt: now,
);

LocalReminderSchedulesCompanion _reminder(String userId, DateTime now) =>
    LocalReminderSchedulesCompanion.insert(
      id: 'shared-reminder',
      userId: userId,
      localTime: '08:00',
      daysOfWeekJson: '[1]',
      timezone: 'Asia/Riyadh',
      localUpdatedAt: now,
    );

LocalRoutineSessionsCompanion _session(
  DateTime now, {
  String id = 'session-1',
  String routineId = 'routine-1',
  int version = 1,
  int target = 60,
  int totalSteps = 1,
}) => LocalRoutineSessionsCompanion.insert(
  id: id,
  userId: 'user-1',
  routineId: routineId,
  routineVersion: version,
  status: 'in_progress',
  startedAt: now,
  targetDurationSeconds: target,
  actualDurationSeconds: 0,
  totalSteps: totalSteps,
  completionPolicyVersion: 'mvp_v1',
  source: 'recommendation',
  localUpdatedAt: now,
);

LocalSessionStepsCompanion _sessionStep(
  String status,
  int activeDurationSeconds,
  DateTime now, {
  String id = 'step-1',
  String sessionId = 'session-1',
  int position = 1,
  int target = 60,
}) => LocalSessionStepsCompanion.insert(
  sessionId: sessionId,
  routineStepId: id,
  exerciseIdSnapshot: 'exercise-1',
  positionSnapshot: position,
  status: status,
  targetDurationSeconds: target,
  activeDurationSeconds: Value(activeDurationSeconds),
  startedAt: (status == 'completed' || status == 'partial')
      ? Value(now)
      : const Value(null),
  finishedAt: status == 'pending' ? const Value(null) : Value(now),
  skipRequested: Value(status == 'skipped'),
  localUpdatedAt: now,
);

Future<void> _seedFiveStepRoutine(AppDatabase database, DateTime now) async {
  await database
      .into(database.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine-5',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 100,
          version: 1,
          updatedAt: now,
        ),
      );
  for (var position = 1; position <= 5; position++) {
    await database
        .into(database.localRoutineSteps)
        .insert(
          LocalRoutineStepsCompanion.insert(
            id: 'routine-5-step-$position',
            routineId: 'routine-5',
            exerciseId: 'exercise-1',
            position: position,
            durationSeconds: 20,
          ),
        );
  }
}

NativeDatabase _v2FixtureExecutor(DateTime now) => NativeDatabase.memory(
  setup: (raw) {
    final millis = now.millisecondsSinceEpoch;
    raw.execute(
      'CREATE TABLE local_profiles ('
      'user_id TEXT NOT NULL PRIMARY KEY, preferred_locale TEXT NOT NULL, '
      'timezone TEXT NOT NULL, weekly_goal_days INTEGER NOT NULL, '
      'onboarding_completed_at INTEGER NULL, sync_state TEXT NOT NULL, '
      'local_updated_at INTEGER NOT NULL, server_updated_at INTEGER NULL, '
      'last_sync_error TEXT NULL)',
    );
    raw.execute(
      "INSERT INTO local_profiles VALUES ('user-1', 'en', 'Asia/Riyadh', 3, NULL, 'synced', $millis, NULL, NULL)",
    );
    raw.execute(
      'CREATE TABLE local_routines ('
      'id TEXT NOT NULL PRIMARY KEY, status TEXT NOT NULL, '
      'access_tier TEXT NOT NULL, difficulty TEXT NOT NULL, '
      'estimated_duration_seconds INTEGER NOT NULL, version INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL)',
    );
    raw.execute(
      "INSERT INTO local_routines VALUES ('routine-1', 'published', 'free', 'beginner', 60, 1, $millis)",
    );
    raw.execute(
      'CREATE TABLE local_routine_steps ('
      'id TEXT NOT NULL PRIMARY KEY, routine_id TEXT NOT NULL, '
      'exercise_id TEXT NOT NULL, position INTEGER NOT NULL, '
      'duration_seconds INTEGER NOT NULL, rest_after_seconds INTEGER NOT NULL DEFAULT 0, '
      'is_optional INTEGER NOT NULL DEFAULT 0)',
    );
    raw.execute(
      "INSERT INTO local_routine_steps VALUES ('step-1', 'routine-1', 'exercise-1', 1, 60, 0, 0)",
    );
    raw.execute(
      'CREATE TABLE local_media_assets ('
      'id TEXT NOT NULL PRIMARY KEY, exercise_id TEXT NOT NULL, media_type TEXT NOT NULL, '
      'storage_key TEXT NOT NULL, mime_type TEXT NOT NULL, checksum_sha256 TEXT NOT NULL, '
      'status TEXT NOT NULL, is_preferred INTEGER NOT NULL DEFAULT 0, '
      'width INTEGER NULL, height INTEGER NULL, duration_ms INTEGER NULL, updated_at INTEGER NOT NULL)',
    );
    raw.execute(
      'CREATE TABLE local_routine_sessions ('
      'id TEXT NOT NULL PRIMARY KEY, user_id TEXT NOT NULL, routine_id TEXT NOT NULL, '
      'routine_version INTEGER NOT NULL, recommendation_id TEXT NULL, status TEXT NOT NULL, '
      'started_at INTEGER NOT NULL, completed_at INTEGER NULL, '
      'target_duration_seconds INTEGER NOT NULL, actual_duration_seconds INTEGER NOT NULL, '
      'total_steps INTEGER NOT NULL, steps_completed INTEGER NOT NULL DEFAULT 0, '
      'steps_partial INTEGER NOT NULL DEFAULT 0, steps_skipped INTEGER NOT NULL DEFAULT 0, '
      'completion_policy_version TEXT NOT NULL, source TEXT NOT NULL, '
      'sync_state TEXT NOT NULL, local_updated_at INTEGER NOT NULL, '
      'server_updated_at INTEGER NULL, last_sync_error TEXT NULL)',
    );
    raw.execute(
      "INSERT INTO local_routine_sessions VALUES ('v2-session', 'user-1', 'routine-1', 1, NULL, 'in_progress', $millis, NULL, 60, 48, 0, 0, 1, 0, 'mvp_v1', 'recommendation', 'pendingUpdate', $millis, NULL, NULL)",
    );
    raw.execute(
      'CREATE TABLE local_session_steps ('
      'session_id TEXT NOT NULL, routine_step_id TEXT NOT NULL, '
      'exercise_id_snapshot TEXT NOT NULL, position_snapshot INTEGER NOT NULL, status TEXT NOT NULL, '
      'target_duration_seconds INTEGER NOT NULL, active_duration_seconds INTEGER NOT NULL DEFAULT 0, '
      'skip_requested INTEGER NOT NULL DEFAULT 0, started_at INTEGER NULL, finished_at INTEGER NULL, '
      'sync_state TEXT NOT NULL, local_updated_at INTEGER NOT NULL, '
      'server_updated_at INTEGER NULL, last_sync_error TEXT NULL, '
      'PRIMARY KEY (session_id, routine_step_id))',
    );
    raw.execute(
      "INSERT INTO local_session_steps VALUES ('v2-session', 'step-1', 'exercise-1', 1, 'partial', 60, 48, 1, $millis, $millis, 'pendingUpdate', $millis, NULL, NULL)",
    );
    raw.execute(
      'CREATE TABLE sync_outbox ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, entity_type TEXT NOT NULL, '
      'entity_id TEXT NOT NULL, owner_user_id TEXT NOT NULL, operation TEXT NOT NULL, '
      'payload_json TEXT NOT NULL, attempt_count INTEGER NOT NULL DEFAULT 0, '
      'next_attempt_at INTEGER NOT NULL, created_at INTEGER NOT NULL)',
    );
    raw.execute(
      "INSERT INTO sync_outbox (entity_type, entity_id, owner_user_id, operation, payload_json, next_attempt_at, created_at) VALUES ('routine_session', 'v2-session', 'user-1', 'upsert', '{\"v\":1,\"id\":\"v2-session\"}', $millis, $millis)",
    );
    raw.execute('PRAGMA user_version = 2');
  },
);

class _MutableClock {
  _MutableClock(this.value);
  DateTime value;
  DateTime call() => value;
}
