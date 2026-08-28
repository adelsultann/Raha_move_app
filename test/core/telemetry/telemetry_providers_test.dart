import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/crash_reporting/crash_reporter_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_consent.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';

void main() {
  test('providers default to disabled telemetry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(analyticsServiceProvider).isEnabled, isFalse);
    expect(container.read(crashReporterProvider).isEnabled, isFalse);
    expect(
      container.read(telemetryConsentStoreProvider).current,
      const TelemetryConsent.disabled(),
    );
  });

  test('enabling the analytics service writes consent back', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(analyticsServiceProvider).setEnabled(true);

    expect(
      container.read(telemetryConsentStoreProvider).current.analyticsEnabled,
      isTrue,
    );
    expect(
      container
          .read(telemetryConsentStoreProvider)
          .current
          .crashReportingEnabled,
      isFalse,
    );
  });

  test('analytics service starts from existing consent', () {
    final container = ProviderContainer(
      overrides: [
        telemetryConsentStoreProvider.overrideWithValue(
          InMemoryConsentStore(
            initial: const TelemetryConsent(
              analyticsEnabled: true,
              crashReportingEnabled: false,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(analyticsServiceProvider).isEnabled, isTrue);
    expect(container.read(crashReporterProvider).isEnabled, isFalse);
  });

  test('providers can be replaced with no-op fakes in tests', () {
    final container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(NoopAnalyticsService()),
        crashReporterProvider.overrideWithValue(NoopCrashReporter()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(analyticsServiceProvider),
      isA<NoopAnalyticsService>(),
    );
    expect(container.read(crashReporterProvider), isA<NoopCrashReporter>());

    container
        .read(analyticsServiceProvider)
        .track(const AnalyticsEvent(name: AnalyticsEventName.routineStarted));
  });
}
