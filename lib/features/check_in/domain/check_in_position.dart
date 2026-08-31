/// The closed MVP usable-position vocabulary for the daily check-in.
///
/// [any] represents "no position restriction" and persists as a null position
/// key. Keys are stable taxonomy keys shared with the content catalog.
enum CheckInPosition {
  seated('seated'),
  standing('standing'),
  floor('floor'),
  any(null);

  const CheckInPosition(this.key);

  /// Null for [any]; otherwise the stable position taxonomy key.
  final String? key;
}
