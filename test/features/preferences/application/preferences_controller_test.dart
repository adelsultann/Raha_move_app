import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/preferences/application/preferences_controller.dart';
import 'package:raha_move/features/preferences/domain/experience_level.dart';
import 'package:raha_move/features/preferences/domain/movement_position.dart';

import '../support/preferences_test_harness.dart';

void main() {
  test('starts with no experience selected and gentle defaults', () {
    final container = buildPreferencesContainer();
    addTearDown(container.dispose);

    final form = container.read(preferencesControllerProvider);

    expect(form.isValid, isFalse);
    expect(form.experienceLevel, isNull);
    expect(form.weeklyGoalDays, 3);
    expect(form.preferredPositions, isEmpty);
    expect(form.reminderInterest, isFalse);
  });

  test('selecting experience makes the form valid', () {
    final container = buildPreferencesContainer();
    addTearDown(container.dispose);
    final controller = container.read(preferencesControllerProvider.notifier);

    controller.selectExperience(ExperienceLevel.beginner);

    expect(container.read(preferencesControllerProvider).isValid, isTrue);
    expect(
      container.read(preferencesControllerProvider).experienceLevel,
      ExperienceLevel.beginner,
    );
  });

  test('toggling a position adds then removes it', () {
    final container = buildPreferencesContainer();
    addTearDown(container.dispose);
    final controller = container.read(preferencesControllerProvider.notifier);

    controller.togglePosition(MovementPosition.seated);
    expect(
      container.read(preferencesControllerProvider).preferredPositions,
      contains(MovementPosition.seated),
    );

    controller.togglePosition(MovementPosition.seated);
    expect(
      container.read(preferencesControllerProvider).preferredPositions,
      isNot(contains(MovementPosition.seated)),
    );
  });

  test('weekly goal is clamped to the supported 1..7 range', () {
    final container = buildPreferencesContainer();
    addTearDown(container.dispose);
    final controller = container.read(preferencesControllerProvider.notifier);

    controller.setWeeklyGoal(99);
    expect(container.read(preferencesControllerProvider).weeklyGoalDays, 7);

    controller.setWeeklyGoal(0);
    expect(container.read(preferencesControllerProvider).weeklyGoalDays, 1);
  });

  test('save persists the draft and records a privacy-safe event', () async {
    final repository = FakePreferencesRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildPreferencesContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);
    final controller = container.read(preferencesControllerProvider.notifier);

    controller.selectExperience(ExperienceLevel.intermediate);
    controller.togglePosition(MovementPosition.standing);
    controller.setWeeklyGoal(4);
    controller.setReminderInterest(true);
    final saved = await controller.save();

    expect(saved, isTrue);
    expect(repository.savedFor, 'guest-1');
    expect(repository.stored, isNotNull);
    expect(repository.stored!.experienceLevel, ExperienceLevel.intermediate);
    expect(repository.stored!.preferredPositions, {MovementPosition.standing});
    expect(repository.stored!.weeklyGoalDays, 4);
    expect(repository.stored!.reminderInterest, isTrue);

    expect(analytics.recordedEvents, hasLength(1));
    final event = analytics.recordedEvents.single;
    expect(event.name, AnalyticsEventName.preferencesSaved);
    expect(event.properties, {
      AnalyticsPropertyKey.experienceLevel: 'intermediate',
      AnalyticsPropertyKey.weeklyGoalDays: 4,
      AnalyticsPropertyKey.reminderInterest: true,
    });
  });

  test('save is a no-op while the required field is missing', () async {
    final repository = FakePreferencesRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildPreferencesContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    final saved = await container
        .read(preferencesControllerProvider.notifier)
        .save();

    expect(saved, isFalse);
    expect(repository.savedFor, isNull);
    expect(repository.stored, isNull);
    expect(analytics.recordedEvents, isEmpty);
  });
}
