import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/reminders/application/reminder_lifecycle_service.dart';
import 'package:raha_move/features/reminders/domain/reminder_repository.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';

import '../support/onboarding_test_harness.dart';

void main() {
  test('build restores the persisted language', () async {
    final repository = FakeOnboardingRepository()..language = AppLanguage.en;
    final container = buildOnboardingContainer(repository: repository);
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale.languageCode, 'en');
  });

  test('build defaults to Arabic when nothing is persisted', () async {
    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale.languageCode, 'ar');
  });

  test(
    'selectLanguage applies, persists, and records a privacy-safe event',
    () async {
      final repository = FakeOnboardingRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildOnboardingContainer(
        repository: repository,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.future);
      await container
          .read(localeControllerProvider.notifier)
          .selectLanguage(AppLanguage.en);

      expect(
        container.read(localeControllerProvider).value!.languageCode,
        'en',
      );
      expect(repository.language, AppLanguage.en);
      expect(repository.languageSavedFor, 'guest-1');
      expect(analytics.recordedEvents, hasLength(1));
      expect(
        analytics.recordedEvents.single.name,
        AnalyticsEventName.languageChanged,
      );
      expect(analytics.recordedEvents.single.properties, {'locale': 'en'});
    },
  );

  test('locale changes reschedule enabled reminder with Arabic then English ARB content without a permission prompt', () async {
    final repository = _ReminderRepository()
      ..schedule = ReminderSchedule.dailyAtSix(
        id: 'reminder-guest-1',
        userId: 'guest-1',
        timezone: 'Asia/Riyadh',
      );
    final platform = _ReminderPlatform();
    final container = buildOnboardingContainer(
      reminderLifecycleService: ReminderLifecycleService(repository, platform),
    );
    addTearDown(container.dispose);

    await container.read(localeControllerProvider.future);
    await container
        .read(localeControllerProvider.notifier)
        .selectLanguage(AppLanguage.ar);
    await container
        .read(localeControllerProvider.notifier)
        .selectLanguage(AppLanguage.en);

    expect(platform.permissionRequests, 0);
    expect(platform.contents.map((content) => content.title), [
      'لحظة لطيفة للحركة',
      'A gentle moment to move',
    ]);
    expect(platform.schedules.every((schedule) => schedule.enabled), isTrue);
  });
}

final class _ReminderRepository implements ReminderRepository {
  ReminderSchedule? schedule;

  @override
  Future<ReminderSchedule?> read(String userId) async => schedule;

  @override
  Future<void> remove(String userId) async => schedule = null;

  @override
  Future<void> save(ReminderSchedule value) async => schedule = value;
}

final class _ReminderPlatform implements ReminderPlatform {
  int permissionRequests = 0;
  final List<ReminderSchedule> schedules = [];
  final List<ReminderNotificationContent> contents = [];

  @override
  Future<void> cancel(String scheduleId) async {}

  @override
  Future<String> currentIanaTimezone() async => 'America/New_York';

  @override
  Future<void> openSettings() async {}

  @override
  Future<ReminderPermission> permissionStatus() async =>
      ReminderPermission.granted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<void> schedule(
    ReminderSchedule schedule,
    ReminderNotificationContent content,
  ) async {
    schedules.add(schedule);
    contents.add(content);
  }
}
