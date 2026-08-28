import '../logging/log_redactor.dart';
import 'analytics_catalog.dart';
import 'analytics_event.dart';

/// Application-owned product-analytics boundary.
///
/// Feature code depends on this interface rather than a vendor SDK so tracking
/// can be disabled or replaced in tests. Implementations must honor the consent
/// gate in [isEnabled] and must never emit an event whose properties were not
/// sanitized.
abstract interface class AnalyticsService {
  /// Whether tracking is currently allowed by the user's consent decision.
  bool get isEnabled;

  /// Applies the user's analytics consent. Disabling immediately stops future
  /// events from being recorded or transmitted.
  void setEnabled(bool enabled);

  /// Records [event] only when [isEnabled] is true.
  void track(AnalyticsEvent event);
}

/// Returns a copy of [event] containing only allowlisted properties with safe
/// primitive values. Non-allowlisted keys are dropped and strings are redacted.
AnalyticsEvent sanitizeAnalyticsEvent(
  AnalyticsEvent event, {
  LogRedactor redactor = const LogRedactor(),
}) {
  return AnalyticsEvent(
    name: event.name,
    properties: redactor.sanitizeFields(
      event.properties,
      allowedKeys: AnalyticsPropertyAllowlist.keys,
    ),
  );
}
