import 'crash_reporter.dart';

/// A disabled crash reporter that drops every report.
final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  bool get isEnabled => false;

  @override
  void setEnabled(bool enabled) {}

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  }) {}
}

/// A consent-gated, in-memory crash reporter for debug and test use.
///
/// Reports are redacted and retained locally so tests and debug builds can
/// inspect them without transmitting data off the device.
final class InMemoryCrashReporter implements CrashReporter {
  InMemoryCrashReporter({this.enabled = false, this.onEnabledChanged});

  final List<CrashReport> recordedReports = <CrashReport>[];
  bool enabled;
  final void Function(bool enabled)? onEnabledChanged;

  @override
  bool get isEnabled => enabled;

  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
    onEnabledChanged?.call(enabled);
  }

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    if (!enabled) {
      return;
    }
    recordedReports.add(sanitizeCrashReport(error, stackTrace, context));
  }

  void clear() => recordedReports.clear();
}
