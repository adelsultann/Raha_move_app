import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/routine_player/application/routine_player_controller.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:raha_move/features/routine_player/application/routine_player_state.dart';
import 'package:raha_move/features/routine_player/domain/playback_session.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';

import '../support/routine_player_test_harness.dart';

void main() {
  group('terminalStateFor', () {
    test('full credited time is completed when not skipped', () {
      expect(
        terminalStateFor(
          creditedSeconds: 5,
          durationSeconds: 5,
          skipRequested: false,
        ),
        StepPlaybackState.completed,
      );
    });

    test('partial credited time is partial regardless of skip', () {
      expect(
        terminalStateFor(
          creditedSeconds: 2,
          durationSeconds: 5,
          skipRequested: true,
        ),
        StepPlaybackState.partial,
      );
    });

    test('zero credited time is skipped', () {
      expect(
        terminalStateFor(
          creditedSeconds: 0,
          durationSeconds: 5,
          skipRequested: true,
        ),
        StepPlaybackState.skipped,
      );
    });
  });

  test(
    'ticking increments creditedSeconds, caps, and advances on completion',
    () async {
      final ticker = FakePlaybackTicker();
      final container = buildRoutinePlayerContainer(ticker: ticker);
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      await pumpReady(container, args);

      ticker.fireTick();
      ticker.fireTick();
      var session = readySession(container, args);
      expect(session.currentStepIndex, 0);
      expect(session.steps[0].creditedSeconds, 2);

      ticker.fireTick(); // reaches 3 -> completes step 1 and advances
      session = readySession(container, args);
      expect(session.currentStepIndex, 1);
      expect(session.steps[0].state, StepPlaybackState.completed);
      expect(session.steps[0].creditedSeconds, 3);

      ticker.fireTick(); // step 2 (duration 5)
      session = readySession(container, args);
      expect(session.steps[0].creditedSeconds, 3); // capped, never 4
      expect(session.steps[1].creditedSeconds, 1);
    },
  );

  test(
    'pause freezes ticking and resume continues without double-count',
    () async {
      final ticker = FakePlaybackTicker();
      final container = buildRoutinePlayerContainer(ticker: ticker);
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      final notifier = await pumpReady(container, args);

      ticker.fireTick();
      expect(readySession(container, args).steps[0].creditedSeconds, 1);

      notifier.pause();
      expect(readySession(container, args).status, PlaybackStatus.paused);

      ticker.fireTick(); // frozen while paused
      expect(readySession(container, args).steps[0].creditedSeconds, 1);

      notifier.resume();
      ticker.fireTick();
      expect(readySession(container, args).steps[0].creditedSeconds, 2);
      expect(readySession(container, args).totalCreditedSeconds, 2);
    },
  );

  test(
    'skip before playback is skipped; after partial playback is partial',
    () async {
      final ticker = FakePlaybackTicker();
      final container = buildRoutinePlayerContainer(ticker: ticker);
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      final notifier = await pumpReady(container, args);

      notifier.skip(); // before any playback
      var session = readySession(container, args);
      expect(session.steps[0].state, StepPlaybackState.skipped);
      expect(session.steps[0].creditedSeconds, 0);
      expect(session.currentStepIndex, 1);

      notifier.previous(); // back to step 0
      ticker.fireTick(); // partial playback
      notifier.skip();

      session = readySession(container, args);
      expect(session.steps[0].state, StepPlaybackState.partial);
      expect(session.steps[0].skipRequested, isTrue);
      expect(session.steps[0].creditedSeconds, 1);
    },
  );

  test('next terminalizes and advances; previous resets and returns', () async {
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(ticker: ticker);
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    final notifier = await pumpReady(container, args);

    ticker.fireTick(); // credited 1 of 3
    notifier.next();
    var session = readySession(container, args);
    expect(session.currentStepIndex, 1);
    expect(session.steps[0].state, StepPlaybackState.partial);
    expect(session.steps[0].skipRequested, isFalse);

    notifier.previous();
    session = readySession(container, args);
    expect(session.currentStepIndex, 0);
    expect(session.steps[0].state, StepPlaybackState.pending);
    expect(session.steps[0].creditedSeconds, 0);
    expect(session.status, PlaybackStatus.playing);
  });

  test(
    'last step completion sets completed, stops ticker, disables wake lock',
    () async {
      final ticker = FakePlaybackTicker();
      final wakeLock = FakeScreenWakeLock();
      final container = buildRoutinePlayerContainer(
        ticker: ticker,
        wakeLock: wakeLock,
      );
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      await pumpReady(container, args);

      // Complete step 1 (3 seconds).
      ticker.fireTick();
      ticker.fireTick();
      ticker.fireTick();
      expect(readySession(container, args).currentStepIndex, 1);

      // Complete the last step (5 seconds).
      for (var i = 0; i < 5; i++) {
        ticker.fireTick();
      }

      final session = readySession(container, args);
      expect(session.status, PlaybackStatus.completed);
      expect(session.isCompleted, isTrue);
      expect(ticker.isRunning, isFalse);
      expect(wakeLock.disableCalls, greaterThanOrEqualTo(1));
    },
  );

  test(
    'emits routine_started exactly once with allowlisted properties',
    () async {
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(analytics: analytics);
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(
        routineId: 'rt-1',
        recommendationId: 'rec-1',
      );
      final notifier = await pumpReady(container, args);

      notifier.pause();
      notifier.resume();

      final started = analytics.recordedEvents
          .where((e) => e.name == 'routine_started')
          .toList();
      expect(started, hasLength(1));
      expect(started.single.properties['routine_id'], 'rt-1');
      expect(started.single.properties['session_id'], isNotNull);
      expect(started.single.properties['source'], 'recommendation');
      expect(started.single.properties['recommendation_id'], 'rec-1');
    },
  );

  test('omits recommendation_id from routine_started when absent', () async {
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildRoutinePlayerContainer(analytics: analytics);
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    await pumpReady(container, args);

    final started = analytics.recordedEvents
        .where((e) => e.name == 'routine_started')
        .single;
    expect(started.properties.containsKey('recommendation_id'), isFalse);
  });

  test('wake lock follows the playback lifecycle', () async {
    final ticker = FakePlaybackTicker();
    final wakeLock = FakeScreenWakeLock();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      wakeLock: wakeLock,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    final notifier = await pumpReady(container, args);

    expect(wakeLock.enableCalls, 1); // start
    expect(wakeLock.disableCalls, 0);

    notifier.pause();
    expect(wakeLock.disableCalls, 1);

    notifier.resume();
    expect(wakeLock.enableCalls, 2);

    notifier.pauseForBackground();
    expect(wakeLock.disableCalls, 2);

    notifier.finish();
    expect(wakeLock.disableCalls, 3);
  });

  // --- RAHA-052: persistence, restore, conflict, and terminalization ---

  test(
    'start persists exactly one session with version, link, and cursor',
    () async {
      final repository = FakeRoutineSessionRepository();
      final container = buildRoutinePlayerContainer(repository: repository);
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(
        routineId: 'rt-1',
        recommendationId: 'rec-1',
      );
      await pumpReady(container, args);

      expect(repository.saves, hasLength(1));
      final save = repository.saves.single;
      expect(save.userId, 'guest-1');
      expect(save.routineId, 'rt-1');
      expect(save.routineVersion, 1);
      expect(save.recommendationId, 'rec-1');
      expect(save.steps, hasLength(2));
      expect(save.steps.every((s) => s.status == 'pending'), isTrue);
      expect(save.currentStepPosition, 1);
      expect(save.currentStepActiveSeconds, 0);
      expect(save.startedAt, isNotNull);
    },
  );

  test('tick persists the cursor locally without a step save', () async {
    final repository = FakeRoutineSessionRepository();
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      repository: repository,
      ticker: ticker,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    await pumpReady(container, args);

    ticker.fireTick();
    await pumpEventQueue();

    expect(repository.cursors, isNotEmpty);
    expect(repository.cursors.last.position, 1);
    expect(repository.cursors.last.seconds, 1);
    // A pure tick only advances the cursor; it does not create a new session.
    expect(repository.saves, hasLength(1));
  });

  test('skip persists the terminalized step and advances the cursor', () async {
    final repository = FakeRoutineSessionRepository();
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      repository: repository,
      ticker: ticker,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    final notifier = await pumpReady(container, args);

    ticker.fireTick(); // 1s on step 1
    notifier.skip();
    await pumpEventQueue();

    final save = repository.saves.last;
    expect(save.steps.first.status, 'partial');
    expect(save.steps.first.activeDurationSeconds, 1);
    expect(save.steps.first.skipRequested, isTrue);
    expect(save.currentStepPosition, 2);
    expect(save.currentStepActiveSeconds, 0);
  });

  test('finishing every step persists a terminal completed session', () async {
    final repository = FakeRoutineSessionRepository();
    final ticker = FakePlaybackTicker();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildRoutinePlayerContainer(
      repository: repository,
      ticker: ticker,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    await pumpReady(container, args);

    for (var i = 0; i < 8; i++) {
      ticker.fireTick();
    }
    await pumpEventQueue();

    expect(readySession(container, args).isCompleted, isTrue);
    final save = repository.saves.last;
    expect(save.currentStepPosition, isNull);
    expect(save.currentStepActiveSeconds, isNull);
    expect(save.steps.every((s) => s.status == 'completed'), isTrue);
    expect(
      analytics.recordedEvents.where((e) => e.name == 'routine_completed'),
      hasLength(1),
    );
  });

  test(
    'abandon terminalizes remaining steps as abandoned, not completed',
    () async {
      final repository = FakeRoutineSessionRepository();
      final ticker = FakePlaybackTicker();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        repository: repository,
        ticker: ticker,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      final notifier = await pumpReady(container, args);

      ticker.fireTick(); // 1s on step 1
      await notifier.abandon();

      final session = readySession(container, args);
      expect(session.isAbandoned, isTrue);
      final save = repository.saves.last;
      expect(save.currentStepPosition, isNull);
      expect(save.explicitlyAbandoned, isTrue);
      expect(
        save.steps.first.status,
        'partial',
      ); // active step keeps credited time
      expect(save.steps.last.status, 'skipped'); // remaining becomes skipped
      expect(
        analytics.recordedEvents.where((e) => e.name == 'routine_abandoned'),
        hasLength(1),
      );
      expect(
        analytics.recordedEvents.where((e) => e.name == 'routine_completed'),
        isEmpty,
      );
    },
  );

  test(
    'restore resumes paused from the durable cursor without routine_started',
    () async {
      final repository = FakeRoutineSessionRepository();
      repository.findByIdResult = RoutineSessionSnapshot(
        sessionId: 'session-1',
        routineId: 'rt-1',
        routineVersion: 1,
        recommendationId: 'rec-1',
        source: 'explore',
        startedAt: DateTime.utc(2026, 8, 29, 12),
        status: 'in_progress',
        currentStepPosition: 1,
        currentStepActiveSeconds: 2,
        steps: const [
          RoutineStepSnapshot(
            stepId: 'step-1',
            exerciseId: 'ex-1',
            position: 1,
            status: 'pending',
            targetDurationSeconds: 3,
            activeDurationSeconds: 0,
            skipRequested: false,
          ),
          RoutineStepSnapshot(
            stepId: 'step-2',
            exerciseId: 'ex-2',
            position: 2,
            status: 'pending',
            targetDurationSeconds: 5,
            activeDurationSeconds: 0,
            skipRequested: false,
          ),
        ],
      );
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        repository: repository,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(
        routineId: 'rt-1',
        sessionId: 'session-1',
      );
      await pumpReadyRestored(container, args);

      final session = readySession(container, args);
      expect(session.status, PlaybackStatus.paused);
      expect(session.currentStepIndex, 0);
      expect(session.sessionId, 'session-1');
      expect(session.steps[0].creditedSeconds, 2);
      expect(
        analytics.recordedEvents.where((e) => e.name == 'routine_started'),
        isEmpty,
      );
      await container
          .read(routinePlayerControllerProvider(args).notifier)
          .abandon();
      final abandoned = analytics.recordedEvents
          .where((event) => event.name == 'routine_abandoned')
          .single;
      expect(abandoned.properties['source'], 'explore');
    },
  );

  test('new start with an in-progress session yields conflict and can abandon-and-start', () async {
    final repository = FakeRoutineSessionRepository();
    repository.resumableResult = RoutineSessionSnapshot(
      sessionId: 'old-session',
      routineId: 'rt-1',
      routineVersion: 1,
      source: 'explore',
      startedAt: DateTime.utc(2026, 8, 29, 12),
      status: 'in_progress',
      currentStepPosition: 1,
      currentStepActiveSeconds: 1,
      steps: const [
        RoutineStepSnapshot(
          stepId: 'step-1',
          exerciseId: 'ex-1',
          position: 1,
          status: 'pending',
          targetDurationSeconds: 3,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
        RoutineStepSnapshot(
          stepId: 'step-2',
          exerciseId: 'ex-2',
          position: 2,
          status: 'pending',
          targetDurationSeconds: 5,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
      ],
    );
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildRoutinePlayerContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(
      routineId: 'rt-1',
      recommendationId: 'rec-1',
    );
    container.listen(routinePlayerControllerProvider(args), (_, _) {});
    await container.read(routinePlaybackPlanProvider(args.routineId).future);
    await container.read(resumableRoutineSessionProvider.future);
    await pumpEventQueue();

    expect(
      container.read(routinePlayerControllerProvider(args)),
      isA<RoutinePlayerConflict>(),
    );
    expect(
      analytics.recordedEvents.where((e) => e.name == 'routine_started'),
      isEmpty,
    );

    final notifier = container.read(
      routinePlayerControllerProvider(args).notifier,
    );
    await notifier.abandonAndStart();
    await pumpEventQueue();

    expect(
      container.read(routinePlayerControllerProvider(args)),
      isA<RoutinePlayerReady>(),
    );
    // The conflicting session was abandoned (terminal, no cursor)...
    final abandonSave = repository.saves.first;
    expect(abandonSave.sessionId, 'old-session');
    expect(abandonSave.currentStepPosition, isNull);
    expect(abandonSave.source, 'explore');
    // ...then a fresh session started.
    final startSave = repository.saves.last;
    expect(startSave.sessionId, isNot('old-session'));
    expect(startSave.currentStepPosition, 1);
    expect(
      analytics.recordedEvents.where((e) => e.name == 'routine_started'),
      hasLength(1),
    );
  });

  test(
    'conflict abandon-and-start emits exactly one routine_abandoned',
    () async {
      final repository = FakeRoutineSessionRepository();
      repository.resumableResult = RoutineSessionSnapshot(
        sessionId: 'old-session',
        routineId: 'rt-1',
        routineVersion: 1,
        recommendationId: 'rec-1',
        source: 'explore',
        startedAt: DateTime.utc(2026, 8, 29, 12),
        status: 'in_progress',
        currentStepPosition: 1,
        currentStepActiveSeconds: 1,
        steps: const [
          RoutineStepSnapshot(
            stepId: 'step-1',
            exerciseId: 'ex-1',
            position: 1,
            status: 'pending',
            targetDurationSeconds: 3,
            activeDurationSeconds: 0,
            skipRequested: false,
          ),
          RoutineStepSnapshot(
            stepId: 'step-2',
            exerciseId: 'ex-2',
            position: 2,
            status: 'pending',
            targetDurationSeconds: 5,
            activeDurationSeconds: 0,
            skipRequested: false,
          ),
        ],
      );
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        repository: repository,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(
        routineId: 'rt-1',
        recommendationId: 'rec-1',
      );
      container.listen(routinePlayerControllerProvider(args), (_, _) {});
      await container.read(routinePlaybackPlanProvider(args.routineId).future);
      await container.read(resumableRoutineSessionProvider.future);
      await pumpEventQueue();

      final notifier = container.read(
        routinePlayerControllerProvider(args).notifier,
      );
      await notifier.abandonAndStart();
      await pumpEventQueue();

      final abandoned = analytics.recordedEvents
          .where((e) => e.name == 'routine_abandoned')
          .toList();
      expect(abandoned, hasLength(1));
      expect(abandoned.single.properties['session_id'], 'old-session');
      expect(abandoned.single.properties['routine_id'], 'rt-1');
      expect(abandoned.single.properties['recommendation_id'], 'rec-1');
      expect(abandoned.single.properties['source'], 'explore');
    },
  );

  test('resumable lookup expires stale sessions before reading', () async {
    final repository = FakeRoutineSessionRepository();
    final container = buildRoutinePlayerContainer(repository: repository);
    addTearDown(container.dispose);

    await container.read(resumableRoutineSessionProvider.future);

    expect(repository.callLog, ['expire', 'resumable']);
  });

  test('restore expires stale sessions before reading by id', () async {
    final repository = FakeRoutineSessionRepository();
    final container = buildRoutinePlayerContainer(repository: repository);
    addTearDown(container.dispose);

    await container.read(routineSessionByIdProvider('session-1').future);

    expect(repository.callLog, ['expire', 'findById']);
  });

  test('cursor write failure is ignored without unhandled exception', () async {
    final repository = FakeRoutineSessionRepository()..failCursor = true;
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      repository: repository,
      ticker: ticker,
    );
    addTearDown(container.dispose);

    final args = const RoutinePlayerArgs(routineId: 'rt-1');
    await pumpReady(container, args);

    ticker.fireTick();
    await pumpEventQueue();

    expect(
      container.read(routinePlayerControllerProvider(args)),
      isA<RoutinePlayerReady>(),
    );
    expect(readySession(container, args).steps[0].creditedSeconds, 1);
  });

  test(
    'authoritative write failure becomes a recoverable save-error state',
    () async {
      final repository = FakeRoutineSessionRepository();
      final ticker = FakePlaybackTicker();
      final container = buildRoutinePlayerContainer(
        repository: repository,
        ticker: ticker,
      );
      addTearDown(container.dispose);

      final args = const RoutinePlayerArgs(routineId: 'rt-1');
      final notifier = await pumpReady(container, args);

      repository.failSave = true;
      notifier.skip();
      await pumpEventQueue();

      expect(
        container.read(routinePlayerControllerProvider(args)),
        isA<RoutinePlayerSaveError>(),
      );

      repository.failSave = false;
      await notifier.retrySave();
      await pumpEventQueue();

      expect(
        container.read(routinePlayerControllerProvider(args)),
        isA<RoutinePlayerReady>(),
      );
      // start + transition (retried once, idempotent; no duplicate session).
      expect(repository.saves, hasLength(2));
      expect(repository.saves.map((s) => s.sessionId).toSet(), hasLength(1));
    },
  );
}

/// Keeps the controller subscribed, resolves the plan + resumable session, and
/// returns the ready controller notifier (new-start mode).
Future<RoutinePlayerController> pumpReady(
  ProviderContainer container,
  RoutinePlayerArgs args,
) async {
  container.listen(routinePlayerControllerProvider(args), (_, _) {});
  await container.read(routinePlaybackPlanProvider(args.routineId).future);
  await container.read(resumableRoutineSessionProvider.future);
  await pumpEventQueue();
  final state = container.read(routinePlayerControllerProvider(args));
  expect(state, isA<RoutinePlayerReady>());
  return container.read(routinePlayerControllerProvider(args).notifier);
}

/// Keeps the controller subscribed and resolves the plan + session-by-id for
/// restore mode. Returns the ready controller notifier.
Future<RoutinePlayerController> pumpReadyRestored(
  ProviderContainer container,
  RoutinePlayerArgs args,
) async {
  container.listen(routinePlayerControllerProvider(args), (_, _) {});
  await container.read(routinePlaybackPlanProvider(args.routineId).future);
  await container.read(routineSessionByIdProvider(args.sessionId!).future);
  await pumpEventQueue();
  final state = container.read(routinePlayerControllerProvider(args));
  expect(state, isA<RoutinePlayerReady>());
  return container.read(routinePlayerControllerProvider(args).notifier);
}
