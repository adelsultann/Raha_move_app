/// The two first-class application languages.
///
/// Enum order carries no prominence: Arabic and English are presented with
/// equal visual weight in the language-selection screen. The [code] is stable
/// and matches `local_profiles.preferred_locale`, `AppLocalizations` locale
/// codes, and the analytics `locale` property.
enum AppLanguage {
  ar('ar'),
  en('en');

  const AppLanguage(this.code);

  /// Stable language code (`ar` or `en`).
  final String code;

  /// Resolves a persisted or wire language code, or null when unsupported.
  static AppLanguage? fromCode(String? code) => switch (code) {
    'ar' => AppLanguage.ar,
    'en' => AppLanguage.en,
    _ => null,
  };
}
