import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/routine_player/application/routine_feedback_controller.dart';
import 'package:raha_move/features/routine_player/application/routine_feedback_state.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback.dart';

import '../support/routine_player_test_harness.dart';

void main() {
  const args = RoutineFeedbackArgs(sessionId: 'session-1', routineId: 'rt-1');

  test(
    'submit persists once and emits one allowlisted feedback_submitted event',
    () async {
      final feedback = FakeRoutineFeedbackRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        feedbackRepository: feedback,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final notifier = await settleFeedback(container, args);
      await notifier.submit(FeedbackRating.muchBetter);

      expect(
        container.read(routineFeedbackControllerProvider(args)),
        isA<RoutineFeedbackSaved>(),
      );
      expect(feedback.saves, hasLength(1));
      expect(feedback.saves.single.userId, 'guest-1');
      expect(feedback.saves.single.sessionId, 'session-1');
      expect(feedback.saves.single.rating, FeedbackRating.muchBetter);

      final events = analytics.recordedEvents
          .where((e) => e.name == 'feedback_submitted')
          .toList();
      expect(events, hasLength(1));
      expect(events.single.properties, <String, Object?>{
        'feedback_rating': 'much_better',
        'session_id': 'session-1',
        'routine_id': 'rt-1',
      });
    },
  );

  test('repeat submit cannot duplicate feedback or analytics', () async {
    final feedback = FakeRoutineFeedbackRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildRoutinePlayerContainer(
      feedbackRepository: feedback,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final notifier = await settleFeedback(container, args);
    await notifier.submit(FeedbackRating.same);
    await notifier.submit(FeedbackRating.muchBetter); // ignored after save

    expect(feedback.saves, hasLength(1));
    expect(feedback.saves.single.rating, FeedbackRating.same);
    expect(
      analytics.recordedEvents
          .where((e) => e.name == 'feedback_submitted')
          .length,
      1,
    );
  });

  test(
    'less_comfortable persists its categorical language-neutral key',
    () async {
      final feedback = FakeRoutineFeedbackRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        feedbackRepository: feedback,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final notifier = await settleFeedback(container, args);
      await notifier.submit(FeedbackRating.lessComfortable);

      expect(feedback.saves.single.rating, FeedbackRating.lessComfortable);
      final event = analytics.recordedEvents
          .where((e) => e.name == 'feedback_submitted')
          .single;
      expect(event.properties['feedback_rating'], 'less_comfortable');
    },
  );

  test(
    'save failure surfaces error retaining rating; retry preserves it',
    () async {
      final feedback = FakeRoutineFeedbackRepository()..failSave = true;
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        feedbackRepository: feedback,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final notifier = await settleFeedback(container, args);
      await notifier.submit(FeedbackRating.littleBetter);

      final errorState = container.read(
        routineFeedbackControllerProvider(args),
      );
      expect(errorState, isA<RoutineFeedbackError>());
      expect(
        (errorState as RoutineFeedbackError).rating,
        FeedbackRating.littleBetter,
      );
      expect(feedback.saves, isEmpty);
      expect(
        analytics.recordedEvents.where((e) => e.name == 'feedback_submitted'),
        isEmpty,
      );

      feedback.failSave = false;
      await notifier.retry();

      final savedState = container.read(
        routineFeedbackControllerProvider(args),
      );
      expect(savedState, isA<RoutineFeedbackSaved>());
      expect(
        (savedState as RoutineFeedbackSaved).rating,
        FeedbackRating.littleBetter,
      );
      expect(feedback.saves, hasLength(1));
      expect(
        analytics.recordedEvents.where((e) => e.name == 'feedback_submitted'),
        hasLength(1),
      );
    },
  );

  test('retry is a no-op outside the error state', () async {
    final feedback = FakeRoutineFeedbackRepository();
    final container = buildRoutinePlayerContainer(feedbackRepository: feedback);
    addTearDown(container.dispose);

    final notifier = await settleFeedback(container, args);
    await notifier.retry(); // idle -> no-op

    expect(feedback.saves, isEmpty);
    expect(
      container.read(routineFeedbackControllerProvider(args)),
      isA<RoutineFeedbackIdle>(),
    );
  });

  test('disabled analytics consent saves but emits no event', () async {
    final feedback = FakeRoutineFeedbackRepository();
    final analytics = InMemoryAnalyticsService(enabled: false);
    final container = buildRoutinePlayerContainer(
      feedbackRepository: feedback,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final notifier = await settleFeedback(container, args);
    await notifier.submit(FeedbackRating.same);

    expect(feedback.saves, hasLength(1));
    expect(analytics.recordedEvents, isEmpty);
  });

  test(
    'a stored response is surfaced without re-emitting or re-writing',
    () async {
      final feedback = FakeRoutineFeedbackRepository()
        ..findResult = FeedbackRating.lessComfortable;
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildRoutinePlayerContainer(
        feedbackRepository: feedback,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      final state = await settleFeedbackState(container, args);
      expect(state, isA<RoutineFeedbackSaved>());
      expect(
        (state as RoutineFeedbackSaved).rating,
        FeedbackRating.lessComfortable,
      );
      expect(feedback.saves, isEmpty);
      expect(
        analytics.recordedEvents.where((e) => e.name == 'feedback_submitted'),
        isEmpty,
      );

      // Re-submission is a no-op from the terminal saved state.
      final notifier = container.read(
        routineFeedbackControllerProvider(args).notifier,
      );
      await notifier.submit(FeedbackRating.muchBetter);
      expect(feedback.saves, isEmpty);
      expect(
        analytics.recordedEvents.where((e) => e.name == 'feedback_submitted'),
        isEmpty,
      );
    },
  );

  test('reopening after a first save never overwrites or re-emits', () async {
    final feedback = FakeRoutineFeedbackRepository();
    final analyticsA = InMemoryAnalyticsService(enabled: true);
    final containerA = buildRoutinePlayerContainer(
      feedbackRepository: feedback,
      analytics: analyticsA,
    );
    addTearDown(containerA.dispose);

    final notifierA = await settleFeedback(containerA, args);
    await notifierA.submit(FeedbackRating.same);
    expect(feedback.saves, hasLength(1));
    expect(
      analyticsA.recordedEvents.where((e) => e.name == 'feedback_submitted'),
      hasLength(1),
    );

    // A fresh controller (simulated reopen) sharing the persisted repository.
    final analyticsB = InMemoryAnalyticsService(enabled: true);
    final containerB = buildRoutinePlayerContainer(
      feedbackRepository: feedback,
      analytics: analyticsB,
    );
    addTearDown(containerB.dispose);

    final stateB = await settleFeedbackState(containerB, args);
    expect(stateB, isA<RoutineFeedbackSaved>());
    expect((stateB as RoutineFeedbackSaved).rating, FeedbackRating.same);
    expect(feedback.saves, hasLength(1)); // no second write
    expect(
      analyticsB.recordedEvents.where((e) => e.name == 'feedback_submitted'),
      isEmpty, // no re-emit
    );
  });
}

/// Subscribes to the controller, lets its async "load existing" initialisation
/// settle, and returns the ready notifier.
Future<RoutineFeedbackController> settleFeedback(
  ProviderContainer container,
  RoutineFeedbackArgs args,
) async {
  await settleFeedbackState(container, args);
  return container.read(routineFeedbackControllerProvider(args).notifier);
}

Future<RoutineFeedbackState> settleFeedbackState(
  ProviderContainer container,
  RoutineFeedbackArgs args,
) async {
  container.listen(routineFeedbackControllerProvider(args), (_, _) {});
  await pumpEventQueue();
  await pumpEventQueue();
  return container.read(routineFeedbackControllerProvider(args));
}
