/// The user's telemetry consent: two independent, optional opt-ins.
///
/// Product analytics and crash reporting default to disabled and can be
/// granted or withdrawn separately, as approved in RAHA-001 (2026-08-28).
final class TelemetryConsent {
  const TelemetryConsent({
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
  });

  const TelemetryConsent.disabled()
    : analyticsEnabled = false,
      crashReportingEnabled = false;

  final bool analyticsEnabled;
  final bool crashReportingEnabled;

  TelemetryConsent copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
  }) {
    return TelemetryConsent(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled:
          crashReportingEnabled ?? this.crashReportingEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetryConsent &&
          other.analyticsEnabled == analyticsEnabled &&
          other.crashReportingEnabled == crashReportingEnabled;

  @override
  int get hashCode => Object.hash(analyticsEnabled, crashReportingEnabled);

  @override
  String toString() =>
      'TelemetryConsent(analyticsEnabled: $analyticsEnabled, '
      'crashReportingEnabled: $crashReportingEnabled)';
}

/// Persistence-ready source of truth for telemetry consent.
///
/// The in-memory implementation below is used until the Profile settings flow
/// (RAHA-064) wires durable storage. Consent defaults to disabled and is never
/// enabled by the store itself.
abstract interface class ConsentStore {
  TelemetryConsent get current;

  Future<void> setAnalytics(bool enabled);

  Future<void> setCrashReporting(bool enabled);
}

/// An in-memory consent store that always starts disabled.
final class InMemoryConsentStore implements ConsentStore {
  InMemoryConsentStore({
    TelemetryConsent initial = const TelemetryConsent.disabled(),
  }) : _current = initial;

  TelemetryConsent _current;

  @override
  TelemetryConsent get current => _current;

  @override
  Future<void> setAnalytics(bool enabled) async {
    _current = _current.copyWith(analyticsEnabled: enabled);
  }

  @override
  Future<void> setCrashReporting(bool enabled) async {
    _current = _current.copyWith(crashReportingEnabled: enabled);
  }
}
