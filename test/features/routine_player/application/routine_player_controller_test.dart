import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/routine_player/application/routine_player_controller.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:raha_move/features/routine_player/application/routine_player_state.dart';
import 'package:raha_move/features/routine_player/domain/playback_session.dart';

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
}

/// Keeps the controller subscribed, resolves the plan, and returns the ready
/// controller notifier.
Future<RoutinePlayerController> pumpReady(
  ProviderContainer container,
  RoutinePlayerArgs args,
) async {
  container.listen(routinePlayerControllerProvider(args), (_, _) {});
  await container.read(routinePlaybackPlanProvider(args.routineId).future);
  await pumpEventQueue();
  final state = container.read(routinePlayerControllerProvider(args));
  expect(state, isA<RoutinePlayerReady>());
  return container.read(routinePlayerControllerProvider(args).notifier);
}
