/// Centralized redaction for any text or structured fields that may leave the
/// device through logs, analytics breadcrumbs, or crash reports.
///
/// This class is pure Dart and has no Flutter or third-party dependencies so it
/// can be reused anywhere privacy boundaries are enforced.
final class LogRedactor {
  const LogRedactor();

  /// Placeholder used for every redacted value.
  static const String redacted = '<redacted>';

  static final RegExp _signedUrl = RegExp(
    r'https?://\S*[?&][^&\s]*(signature|x-amz-[a-z-]+|x-goog-[a-z-]+|'
    r'token|key|credential|expires|auth)\s*=\s*[^&\s]+',
    caseSensitive: false,
  );

  static final RegExp _mediaUrl = RegExp(
    r'https?://\S*(storage/v1/object|/storage/)\S*',
  );

  static final RegExp _jwt = RegExp(r'eyJ[A-Za-z0-9._\-]+');

  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
  );

  static final RegExp _phone = RegExp(r'\+[0-9()\-\s]{7,}');

  static final RegExp _longHexToken = RegExp(r'\b[0-9a-fA-F]{32,}\b');

  static final RegExp _authHeader = RegExp(
    r'\b(bearer|basic)\s+[A-Za-z0-9._\-]+',
    caseSensitive: false,
  );

  static final RegExp _secretAssignment = RegExp(
    r'\b(api[_-]?key|secret|password|token|client[_-]?secret|'
    r'access[_-]?token|refresh[_-]?token)\s*[:=]\s*[^\s,;]+',
    caseSensitive: false,
  );

  static final List<RegExp> _wholeMatchPatterns = <RegExp>[
    _signedUrl,
    _mediaUrl,
    _jwt,
    _email,
    _phone,
    _longHexToken,
  ];

  /// Returns [input] with every recognized sensitive value replaced by
  /// [redacted]. Credential labels (`Bearer`, `api_key`, `password`, ...) are
  /// preserved so the engineer can still see which value was removed.
  String redact(String input) {
    var result = input;
    for (final pattern in _wholeMatchPatterns) {
      result = result.replaceAll(pattern, redacted);
    }
    result = result.replaceAllMapped(
      _authHeader,
      (match) => '${match.group(1)} $redacted',
    );
    result = result.replaceAllMapped(
      _secretAssignment,
      (match) => '${match.group(1)}=$redacted',
    );
    return result;
  }

  /// Returns a new map containing only [allowedKeys], with every string value
  /// redacted and every non-primitive value dropped.
  ///
  /// This is the primary defense against sensitive free text and accidental
  /// object graphs reaching logs, analytics, or crash reports.
  Map<String, Object?> sanitizeFields(
    Map<String, Object?> fields, {
    required Set<String> allowedKeys,
  }) {
    final result = <String, Object?>{};
    for (final entry in fields.entries) {
      if (!allowedKeys.contains(entry.key)) {
        continue;
      }
      result[entry.key] = sanitizeValue(entry.value);
    }
    return result;
  }

  /// Coerces a single value to a safe primitive: `null`, `bool`, and `num`
  /// pass through, strings are redacted, and everything else is dropped.
  Object? sanitizeValue(Object? value) {
    if (value == null || value is bool || value is num) {
      return value;
    }
    if (value is String) {
      return redact(value);
    }
    return null;
  }
}
