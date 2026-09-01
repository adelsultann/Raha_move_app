/// A post-routine well-being response (RAHA-053).
///
/// Values are language-neutral and map 1:1 to the `feedback_rating` enum used
/// by the local database and the RAHA-025 `feedback_upsert` wire contract. They
/// never carry free text, raw health answers, or identifiers.
enum FeedbackRating {
  muchBetter('much_better'),
  littleBetter('little_better'),
  same('same'),
  lessComfortable('less_comfortable');

  const FeedbackRating(this.key);

  /// The stable, language-neutral value persisted locally and synchronized.
  final String key;

  /// Whether this response triggers the safety-approved, non-celebratory
  /// acknowledgment and feeds the recommendation history's discomfort input.
  bool get isLessComfortable => this == FeedbackRating.lessComfortable;

  /// Resolves a persisted [key] back to its enum value. Keys are constrained by
  /// the database, so this never throws for persisted rows.
  static FeedbackRating fromKey(String key) =>
      values.firstWhere((rating) => rating.key == key);
}
