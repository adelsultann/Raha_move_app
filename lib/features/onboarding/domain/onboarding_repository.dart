import 'app_language.dart';

/// Owns the persisted startup preferences that decide whether a user is routed
/// to language selection and onboarding or straight to the app.
///
/// Reads and writes the local profile only; synchronization is a separate
/// concern owned by later profile-sync work.
abstract interface class OnboardingRepository {
  /// The persisted preferred language, defaulting to Arabic when absent.
  Future<AppLanguage> readPreferredLanguage(String userId);

  /// Whether onboarding has already been completed for [userId].
  Future<bool> isOnboardingComplete(String userId);

  /// Persists [language] as the user's preferred language (local-first).
  Future<void> savePreferredLanguage(String userId, AppLanguage language);

  /// Marks onboarding complete for [userId] at the injected clock's now.
  Future<void> markOnboardingComplete(String userId);
}
