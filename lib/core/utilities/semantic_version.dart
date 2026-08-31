/// Minimal semantic-version parsing and comparison for the RAHA-024 release
/// compatibility gate and the RAHA-041 recommendation app-version filter.
///
/// Only `MAJOR.MINOR.PATCH` is accepted; pre-release and build metadata are not
/// part of the MVP release contract.
final class SemanticVersion implements Comparable<SemanticVersion> {
  const SemanticVersion(this.major, this.minor, this.patch);

  factory SemanticVersion.parse(String value) {
    final parts = value.trim().split('.');
    if (parts.length != 3) {
      throw const FormatException('Version must be MAJOR.MINOR.PATCH');
    }
    int parsePart(String part) {
      if (part.isEmpty || !part.codeUnits.every(_isDigit)) {
        throw FormatException('Invalid numeric version part: "$part"');
      }
      return int.parse(part);
    }

    return SemanticVersion(
      parsePart(parts[0]),
      parsePart(parts[1]),
      parsePart(parts[2]),
    );
  }

  /// Returns `null` when [value] is not a valid `MAJOR.MINOR.PATCH` version.
  static SemanticVersion? tryParse(String? value) {
    if (value == null) return null;
    try {
      return SemanticVersion.parse(value);
    } on FormatException {
      return null;
    }
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(SemanticVersion other) {
    for (final pair in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      final comparison = pair.$1.compareTo(pair.$2);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  bool operator ==(Object other) =>
      other is SemanticVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}
