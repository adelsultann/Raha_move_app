/// Server-owned achievement definition and the active user's earned state.
///
/// The server sends the versioned rule and localized content as an opaque,
/// read-only projection. Clients never evaluate or award achievements.
final class AchievementProgress {
  const AchievementProgress({
    required this.key,
    required this.category,
    required this.criteriaVersion,
    required this.ruleVersion,
    required this.iconKey,
    required this.status,
    required this.translations,
    this.earnedAt,
    this.sourceId,
    this.earnedCriteriaVersion,
  });

  final String key;
  final String category;
  final int criteriaVersion;
  final String ruleVersion;
  final String iconKey;
  final String status;
  final Map<String, AchievementTranslation> translations;
  final DateTime? earnedAt;
  final String? sourceId;
  final int? earnedCriteriaVersion;

  bool get isEarned => earnedAt != null;

  /// Uses English only as the approved content fallback when a translation is
  /// unavailable. The raw server payload is never presented to the user.
  AchievementTranslation? translationFor(String locale) =>
      translations[locale] ?? translations['en'];
}

final class AchievementTranslation {
  const AchievementTranslation({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
