import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/telemetry/telemetry_consent.dart';

void main() {
  group('TelemetryConsent', () {
    test('defaults to disabled', () {
      const consent = TelemetryConsent.disabled();
      expect(consent.analyticsEnabled, isFalse);
      expect(consent.crashReportingEnabled, isFalse);
    });

    test('analytics and crash consent are independent', () {
      const consent = TelemetryConsent(
        analyticsEnabled: true,
        crashReportingEnabled: false,
      );
      expect(consent.analyticsEnabled, isTrue);
      expect(consent.crashReportingEnabled, isFalse);
    });

    test('copyWith preserves unspecified flags', () {
      const consent = TelemetryConsent(
        analyticsEnabled: true,
        crashReportingEnabled: false,
      );
      final updated = consent.copyWith(crashReportingEnabled: true);
      expect(updated.analyticsEnabled, isTrue);
      expect(updated.crashReportingEnabled, isTrue);
    });

    test('value equality', () {
      const a = TelemetryConsent(
        analyticsEnabled: true,
        crashReportingEnabled: false,
      );
      const b = TelemetryConsent(
        analyticsEnabled: true,
        crashReportingEnabled: false,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('InMemoryConsentStore', () {
    test('starts disabled and toggles separately', () async {
      final store = InMemoryConsentStore();
      expect(store.current.analyticsEnabled, isFalse);
      expect(store.current.crashReportingEnabled, isFalse);

      await store.setAnalytics(true);
      expect(store.current.analyticsEnabled, isTrue);
      expect(store.current.crashReportingEnabled, isFalse);

      await store.setCrashReporting(true);
      expect(store.current.crashReportingEnabled, isTrue);
      expect(store.current.analyticsEnabled, isTrue);

      await store.setAnalytics(false);
      expect(store.current.analyticsEnabled, isFalse);
      expect(store.current.crashReportingEnabled, isTrue);
    });
  });
}
