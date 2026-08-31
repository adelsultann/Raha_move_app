import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/check_in/application/check_in_controller.dart';
import 'package:raha_move/features/check_in/domain/body_area.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_goal.dart';
import 'package:raha_move/features/check_in/domain/check_in_position.dart';

import '../support/check_in_test_harness.dart';

void main() {
  test('starts with every step unanswered and invalid', () {
    final container = buildCheckInContainer();
    addTearDown(container.dispose);

    final form = container.read(checkInControllerProvider);

    expect(form.isValid, isFalse);
    expect(form.bodyState, isNull);
    expect(form.goal, isNull);
    expect(form.bodyAreas, isEmpty);
    expect(form.availableMinutes, isNull);
    expect(form.position, isNull);
  });

  test('answering every step makes the form valid', () {
    final container = buildCheckInContainer();
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.selectBodyState(BodyState.stiff);
    controller.selectGoal(CheckInGoal.easeStiffness);
    controller.toggleBodyArea(BodyArea.neck);
    controller.toggleBodyArea(BodyArea.shoulders);
    controller.selectTime(5);
    controller.selectPosition(CheckInPosition.seated);

    final form = container.read(checkInControllerProvider);
    expect(form.isValid, isTrue);
    expect(form.toAnswers().bodyAreaKeys, {'neck', 'shoulders'});
  });

  test('toggling a body area adds then removes it', () {
    final container = buildCheckInContainer();
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.toggleBodyArea(BodyArea.hips);
    expect(
      container.read(checkInControllerProvider).bodyAreas,
      contains(BodyArea.hips),
    );

    controller.toggleBodyArea(BodyArea.hips);
    expect(
      container.read(checkInControllerProvider).bodyAreas,
      isNot(contains(BodyArea.hips)),
    );
  });

  test('selectTime rejects an unsupported duration', () {
    final container = buildCheckInContainer();
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    expect(() => controller.selectTime(7), throwsArgumentError);
  });

  test('complete persists the draft and records a categorical event', () async {
    final repository = FakeCheckInRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildCheckInContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.selectBodyState(BodyState.tense);
    controller.selectGoal(CheckInGoal.relax);
    controller.toggleBodyArea(BodyArea.lowerBack);
    controller.selectTime(10);
    controller.selectPosition(CheckInPosition.floor);

    final saved = await controller.complete();

    expect(saved, isTrue);
    expect(repository.savedFor, 'guest-1');
    expect(repository.savedId, isNotEmpty);
    expect(repository.savedStartedAt, isNotNull);
    expect(repository.savedAnswers!.bodyState, BodyState.tense);
    expect(repository.savedAnswers!.goalKey, 'relax');
    expect(repository.savedAnswers!.bodyAreaKeys, {'lower_back'});
    expect(repository.savedAnswers!.availableMinutes, 10);
    expect(repository.savedAnswers!.positionKey, 'floor');

    final event = analytics.recordedEvents.single;
    expect(event.name, AnalyticsEventName.checkInCompleted);
    expect(event.properties, {
      AnalyticsPropertyKey.bodyState: 'tense',
      AnalyticsPropertyKey.goalKey: 'relax',
      AnalyticsPropertyKey.availableMinutes: 10,
      AnalyticsPropertyKey.positionKey: 'floor',
      AnalyticsPropertyKey.bodyAreaCount: 1,
    });
  });

  test('"any position" persists null and records "any" in analytics', () async {
    final repository = FakeCheckInRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildCheckInContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.selectBodyState(BodyState.comfortable);
    controller.selectGoal(CheckInGoal.deskBreak);
    controller.toggleBodyArea(BodyArea.fullBody);
    controller.selectTime(3);
    controller.selectPosition(CheckInPosition.any);

    final saved = await controller.complete();

    expect(saved, isTrue);
    expect(repository.savedAnswers!.positionKey, isNull);
    expect(
      analytics.recordedEvents.single.properties[AnalyticsPropertyKey
          .positionKey],
      'any',
    );
  });

  test('complete is a no-op while the form is invalid', () async {
    final repository = FakeCheckInRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildCheckInContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final saved = await container
        .read(checkInControllerProvider.notifier)
        .complete();

    expect(saved, isFalse);
    expect(repository.saveCount, 0);
    expect(analytics.recordedEvents, isEmpty);
  });

  test('complete is idempotent and does not re-emit analytics', () async {
    final repository = FakeCheckInRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildCheckInContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.selectBodyState(BodyState.stiff);
    controller.selectGoal(CheckInGoal.easeStiffness);
    controller.toggleBodyArea(BodyArea.neck);
    controller.selectTime(5);
    controller.selectPosition(CheckInPosition.seated);

    await controller.complete();
    final firstId = repository.savedId;
    final second = await controller.complete();

    expect(second, isTrue);
    expect(repository.saveCount, 1);
    expect(repository.savedId, firstId);
    expect(analytics.recordedEvents, hasLength(1));
  });

  test('retry after a failed save reuses the same check-in id', () async {
    final repository = FakeCheckInRepository()..saveError = StateError('boom');
    final container = buildCheckInContainer(repository: repository);
    addTearDown(container.dispose);
    final controller = container.read(checkInControllerProvider.notifier);

    controller.selectBodyState(BodyState.stiff);
    controller.selectGoal(CheckInGoal.easeStiffness);
    controller.toggleBodyArea(BodyArea.neck);
    controller.selectTime(5);
    controller.selectPosition(CheckInPosition.seated);

    await expectLater(controller.complete(), throwsA(isA<StateError>()));
    repository.saveError = null;
    final saved = await controller.complete();

    expect(saved, isTrue);
    expect(repository.saveCount, 1);
    expect(repository.savedId, isNotEmpty);
  });
}
