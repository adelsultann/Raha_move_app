import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_language.dart';
import '../domain/onboarding_repository.dart';

/// Drift-backed [OnboardingRepository] reading and writing `local_profiles`.
final class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<AppLanguage> readPreferredLanguage(String userId) async {
    final profile = await _profile(userId);
    return AppLanguage.fromCode(profile?.preferredLocale) ?? AppLanguage.ar;
  }

  @override
  Future<bool> isOnboardingComplete(String userId) async {
    final profile = await _profile(userId);
    return profile?.onboardingCompletedAt != null;
  }

  @override
  Future<void> savePreferredLanguage(
    String userId,
    AppLanguage language,
  ) async {
    await (_database.update(
      _database.localProfiles,
    )..where((r) => r.userId.equals(userId))).write(
      LocalProfilesCompanion(
        preferredLocale: Value(language.code),
        localUpdatedAt: Value(_clock()),
      ),
    );
  }

  @override
  Future<void> markOnboardingComplete(String userId) async {
    final now = _clock();
    await (_database.update(
      _database.localProfiles,
    )..where((r) => r.userId.equals(userId))).write(
      LocalProfilesCompanion(
        onboardingCompletedAt: Value(now),
        localUpdatedAt: Value(now),
      ),
    );
  }

  Future<LocalProfile?> _profile(String userId) => (_database.select(
    _database.localProfiles,
  )..where((r) => r.userId.equals(userId))).getSingleOrNull();
}
