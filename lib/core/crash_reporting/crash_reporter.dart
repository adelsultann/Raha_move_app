import '../logging/log_redactor.dart';

/// Keys that may appear in crash context. Anything else is dropped before the
/// report is recorded or transmitted.
abstract final class CrashContextAllowlist {
  static const Set<String> keys = <String>{
    'app_version',
    'platform',
    'os_version',
    'locale',
    'session_id',
    'routine_id',
    'build_environment',
  };
}

/// A crash report whose error text and context have already been redacted.
final class CrashReport {
  const CrashReport({
    required this.error,
    required this.stackTrace,
    this.context = const <String, Object?>{},
  });

  /// Redacted error description.
  final String error;
  final StackTrace stackTrace;
  final Map<String, Object?> context;
}

/// Application-owned crash-reporting boundary.
///
/// Implementations must strip tokens, private media URLs, and sensitive user
/// content before a report leaves the device, and must honor [isEnabled].
abstract interface class CrashReporter {
  bool get isEnabled;

  /// Applies the user's crash-reporting consent.
  void setEnabled(bool enabled);

  /// Records a redacted report only when [isEnabled] is true.
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  });
}

/// Redacts the error text and allowlists the context before constructing a
/// [CrashReport].
CrashReport sanitizeCrashReport(
  Object error,
  StackTrace stackTrace,
  Map<String, Object?> context, {
  LogRedactor redactor = const LogRedactor(),
}) {
  return CrashReport(
    error: redactor.redact(error.toString()),
    stackTrace: stackTrace,
    context: redactor.sanitizeFields(
      context,
      allowedKeys: CrashContextAllowlist.keys,
    ),
  );
}
