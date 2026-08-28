/// An immutable, language-neutral analytics event.
///
/// [name] is a stable identifier from [AnalyticsEventName]. [properties] holds
/// only approved categorical values and stable Raha identifiers; it must never
/// contain names, emails, free text, signed URLs, or provider payloads.
final class AnalyticsEvent {
  const AnalyticsEvent({required this.name, this.properties = const {}});

  final String name;
  final Map<String, Object?> properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsEvent &&
          other.name == name &&
          _mapsEqual(other.properties, properties);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(properties.entries));

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

  @override
  String toString() => 'AnalyticsEvent(name: $name, properties: $properties)';
}
