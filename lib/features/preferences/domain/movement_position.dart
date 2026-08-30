/// The closed set of movement positions the MVP supports as a preference.
///
/// Keys are stable, language-neutral, and match the position taxonomy keys used
/// by the content catalog (`seated`, `standing`, `floor`). An empty set of
/// preferred positions means "any position" rather than "none".
enum MovementPosition {
  seated('seated'),
  standing('standing'),
  floor('floor');

  const MovementPosition(this.key);

  /// The stable taxonomy key, never a provider ID or localized label.
  final String key;

  static MovementPosition fromKey(String key) =>
      values.firstWhere((position) => position.key == key);
}
