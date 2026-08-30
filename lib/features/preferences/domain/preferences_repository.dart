import 'user_preferences.dart';

/// Owns reading and writing a user's basic preferences.
///
/// Persistence is local-first (Drift) and atomic; synchronization is a separate
/// concern owned by the future preference wire-contract work. See the RAHA-032
/// decision note.
abstract interface class PreferencesRepository {
  /// The stored preferences for [userId], or null when none have been saved.
  Future<UserPreferences?> read(String userId);

  /// Persists [preferences] for [userId] locally and atomically.
  Future<void> save(String userId, UserPreferences preferences);
}
