import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';

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
}
