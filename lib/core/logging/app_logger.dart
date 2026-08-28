import 'log_redactor.dart';

/// Severity of a diagnostic entry.
enum LogLevel { debug, info, warning, error }

/// Keys that may appear in structured log fields. Anything else is dropped by
/// [PrivacySafeLogger] before the entry reaches a sink.
abstract final class LogFieldAllowlist {
  static const Set<String> keys = <String>{
    'event_name',
    'session_id',
    'routine_id',
    'recommendation_id',
    'check_in_id',
    'locale',
    'error_code',
    'retry_count',
    'duration_ms',
    'sync_state',
    'build_environment',
  };
}

/// A single diagnostic entry whose message and fields have already passed
/// redaction.
final class LogEntry {
  const LogEntry({
    required this.level,
    required this.message,
    this.fields = const <String, Object?>{},
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;
  final Map<String, Object?> fields;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          other.level == level &&
          other.message == message &&
          _mapsEqual(other.fields, fields) &&
          other.error == error &&
          other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(
    level,
    message,
    error,
    stackTrace,
    Object.hashAll(fields.entries),
  );

  static bool _mapsEqual(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

/// Application-owned logging boundary. Feature code logs through this interface
/// rather than `print` or a vendor SDK.
abstract interface class AppLogger {
  void debug(String message, [Map<String, Object?> fields = const {}]);
  void info(String message, [Map<String, Object?> fields = const {}]);
  void warning(String message, [Map<String, Object?> fields = const {}]);
  void error(
    String message,
    Object error,
    StackTrace stackTrace, [
    Map<String, Object?> fields = const {},
  ]);
}

/// Receives already-sanitized entries. Replacements include the no-op sink and
/// the in-memory sink used by tests and debug builds.
abstract interface class LogSink {
  void write(LogEntry entry);
}

/// Drops every entry. This is the safest default until a diagnostic transport
/// is approved.
final class NoopLogSink implements LogSink {
  const NoopLogSink();

  @override
  void write(LogEntry entry) {}
}

/// Retains sanitized entries in memory for inspection in tests and debug
/// builds. It never transmits data off the device.
final class InMemoryLogSink implements LogSink {
  InMemoryLogSink();

  final List<LogEntry> entries = <LogEntry>[];

  @override
  void write(LogEntry entry) => entries.add(entry);

  void clear() => entries.clear();
}

/// Applies centralized redaction and field allowlisting before delegating to a
/// [LogSink], guaranteeing sensitive data never reaches the sink.
final class PrivacySafeLogger implements AppLogger {
  PrivacySafeLogger({required this.sink, this.redactor = const LogRedactor()});

  final LogSink sink;
  final LogRedactor redactor;

  @override
  void debug(String message, [Map<String, Object?> fields = const {}]) {
    _write(LogLevel.debug, message, fields);
  }

  @override
  void info(String message, [Map<String, Object?> fields = const {}]) {
    _write(LogLevel.info, message, fields);
  }

  @override
  void warning(String message, [Map<String, Object?> fields = const {}]) {
    _write(LogLevel.warning, message, fields);
  }

  @override
  void error(
    String message,
    Object error,
    StackTrace stackTrace, [
    Map<String, Object?> fields = const {},
  ]) {
    _write(
      LogLevel.error,
      message,
      fields,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _write(
    LogLevel level,
    String message,
    Map<String, Object?> fields, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    sink.write(
      LogEntry(
        level: level,
        message: redactor.redact(message),
        fields: redactor.sanitizeFields(
          fields,
          allowedKeys: LogFieldAllowlist.keys,
        ),
        error: error == null ? null : redactor.redact(error.toString()),
        stackTrace: stackTrace,
      ),
    );
  }
}
