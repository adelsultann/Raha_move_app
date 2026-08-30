/// A user's self-assessed familiarity with movement. The values mirror the
/// catalog `difficulty_level` taxonomy so a preference maps directly to the
/// difficulty a recommendation should favor, but it is a distinct, stable
/// product concept owned by the preferences feature.
enum ExperienceLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  const ExperienceLevel(this.code);

  /// The stable, language-neutral storage code (also the analytics value).
  final String code;

  static ExperienceLevel fromCode(String? code) => values.firstWhere(
    (level) => level.code == code,
    orElse: () => ExperienceLevel.beginner,
  );
}
