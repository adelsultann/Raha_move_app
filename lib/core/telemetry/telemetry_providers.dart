import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../analytics/analytics_service.dart';
import '../analytics/analytics_service_impls.dart';
import '../crash_reporting/crash_reporter.dart';
import '../crash_reporting/crash_reporter_impls.dart';
import '../logging/app_logger.dart';
import 'telemetry_consent.dart';

part 'telemetry_providers.g.dart';

/// The shared consent store. It starts disabled; the Profile settings flow
/// (RAHA-064) will replace the in-memory implementation with durable storage.
@Riverpod(keepAlive: true)
ConsentStore telemetryConsentStore(Ref ref) => InMemoryConsentStore();

/// The analytics service used by feature code. Enabled state is initialized
/// from consent and written back whenever the service is toggled, keeping
/// consent authoritative.
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  final consent = ref.watch(telemetryConsentStoreProvider);
  return InMemoryAnalyticsService(
    enabled: consent.current.analyticsEnabled,
    onEnabledChanged: (enabled) {
      consent.setAnalytics(enabled);
    },
  );
}

/// The crash reporter used by feature code, gated by the separate
/// crash-reporting consent.
@Riverpod(keepAlive: true)
CrashReporter crashReporter(Ref ref) {
  final consent = ref.watch(telemetryConsentStoreProvider);
  return InMemoryCrashReporter(
    enabled: consent.current.crashReportingEnabled,
    onEnabledChanged: (enabled) {
      consent.setCrashReporting(enabled);
    },
  );
}

/// The privacy-safe logger. It defaults to a no-op sink so no diagnostic data
/// is retained or transmitted until a transport is approved.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => PrivacySafeLogger(sink: const NoopLogSink());
