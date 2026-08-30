import 'dart:convert';

/// Canonical JSON encoding shared by the RAHA-024 content-release contract.
///
/// The backend computes a release `manifest_checksum` as the lower-case hex
/// SHA-256 of the UTF-8 bytes of the PostgreSQL `jsonb::text` representation of
/// the manifest. This encoder reproduces that exact textual form so the mobile
/// client can verify the same checksum for bundled starter content and for any
/// release source that does not hand back pre-canonicalized bytes.
///
/// The canonical form is:
///   * Object keys are sorted by UTF-8 byte length first, then bytewise
///     (PostgreSQL `jsonb` key ordering), not by code point.
///   * Objects render as `{"key": value, "key2": value2}`: no space after `{`
///     or before `}`, one ASCII space after `:` and after `,`.
///   * Arrays render as `[v1, v2]`: no space after `[` or before `]`, one ASCII
///     space after `,`.
///   * Strings are escaped per RFC 8259 using PostgreSQL's `escape_json` rules:
///     `"`, `\`, backspace, form feed, newline, carriage return, and tab use the
///     short escapes; other control characters use `\u00XX` (lower-case hex);
///     non-ASCII characters are emitted as their UTF-8 bytes directly.
///   * Integers render without a decimal point; finite doubles render using
///     Dart's shortest round-trip decimal, with an explicit `.0` suffix when the
///     value is integral (mirroring PostgreSQL float-to-jsonb output).
///
/// This encoder operates on plain decoded JSON values (`Map`, `List`, `String`,
/// `num`, `bool`, and `null`). Callers pass the raw decoded manifest map rather
/// than a re-serialized typed model so that key names, value types, and array
/// order are preserved exactly.
final class CanonicalJson {
  const CanonicalJson._();

  static String encode(Object? value) {
    final buffer = StringBuffer();
    _write(buffer, value);
    return buffer.toString();
  }

  /// Canonical UTF-8 bytes for [value].
  static List<int> encodeBytes(Object? value) => utf8.encode(encode(value));

  static void _write(StringBuffer buffer, Object? value) {
    if (value == null) {
      buffer.write('null');
      return;
    }
    if (value is bool) {
      buffer.write(value ? 'true' : 'false');
      return;
    }
    if (value is String) {
      _writeString(buffer, value);
      return;
    }
    if (value is int) {
      buffer.write(value.toString());
      return;
    }
    if (value is double) {
      _writeDouble(buffer, value);
      return;
    }
    if (value is Map) {
      _writeObject(buffer, value);
      return;
    }
    if (value is List) {
      _writeArray(buffer, value);
      return;
    }
    throw ArgumentError.value(
      value,
      'value',
      'Unsupported canonical JSON value type',
    );
  }

  static void _writeObject(StringBuffer buffer, Map map) {
    final keys = map.keys.map((key) => key.toString()).toList()
      ..sort(_compareJsonbKeys);
    buffer.write('{');
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) buffer.write(', ');
      _writeString(buffer, keys[i]);
      buffer.write(': ');
      _write(buffer, map[keys[i]]);
    }
    buffer.write('}');
  }

  static void _writeArray(StringBuffer buffer, List list) {
    buffer.write('[');
    for (var i = 0; i < list.length; i++) {
      if (i > 0) buffer.write(', ');
      _write(buffer, list[i]);
    }
    buffer.write(']');
  }

  static void _writeString(StringBuffer buffer, String value) {
    buffer.write('"');
    for (var i = 0; i < value.length; i++) {
      final codeUnit = value.codeUnitAt(i);
      if (codeUnit == 0x08) {
        buffer.write(r'\b');
      } else if (codeUnit == 0x0C) {
        buffer.write(r'\f');
      } else if (codeUnit == 0x0A) {
        buffer.write(r'\n');
      } else if (codeUnit == 0x0D) {
        buffer.write(r'\r');
      } else if (codeUnit == 0x09) {
        buffer.write(r'\t');
      } else if (codeUnit == 0x22) {
        buffer.write(r'\"');
      } else if (codeUnit == 0x5C) {
        buffer.write(r'\\');
      } else if (codeUnit < 0x20) {
        buffer.write('\\u00${codeUnit.toRadixString(16).padLeft(2, "0")}');
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    buffer.write('"');
  }

  static void _writeDouble(StringBuffer buffer, double value) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError.value(value, 'value', 'Non-finite JSON number');
    }
    if (value == value.truncateToDouble()) {
      buffer.write('${value.toInt()}.0');
    } else {
      buffer.write(value.toString());
    }
  }

  /// PostgreSQL `jsonb` orders object keys by byte length first, then by
  /// unsigned byte value. Dart's default string ordering is code-point based,
  /// so compare the UTF-8 encodings explicitly.
  static int _compareJsonbKeys(String a, String b) {
    final bytesA = utf8.encode(a);
    final bytesB = utf8.encode(b);
    final lengthCompare = bytesA.length.compareTo(bytesB.length);
    if (lengthCompare != 0) return lengthCompare;
    for (var i = 0; i < bytesA.length; i++) {
      final byteCompare = bytesA[i].compareTo(bytesB[i]);
      if (byteCompare != 0) return byteCompare;
    }
    return 0;
  }
}
