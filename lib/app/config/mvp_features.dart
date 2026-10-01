/// Compile-time switches for features intentionally deferred from the first
/// MVP release.
///
/// The implementation remains in the repository so it can be tested and
/// restored later. A non-MVP build can opt in with the corresponding
/// `--dart-define` without scattering commented-out code across features.
abstract final class MvpFeatures {
  static const preferences = bool.fromEnvironment(
    'RAHA_ENABLE_PREFERENCES',
    defaultValue: false,
  );

  static const recommendations = bool.fromEnvironment(
    'RAHA_ENABLE_RECOMMENDATIONS',
    defaultValue: false,
  );

  static const gamification = bool.fromEnvironment(
    'RAHA_ENABLE_GAMIFICATION',
    defaultValue: false,
  );
}
