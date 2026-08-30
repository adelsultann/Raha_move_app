import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  late AppDatabase database;
  late DriftOnboardingRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftOnboardingRepository(database, clock: () => now);
  });

  tearDown(() => database.close());

  Future<void> seedProfile(String userId) => database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: userId,
          preferredLocale: 'ar',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );

  test(
    'readPreferredLanguage defaults to Arabic when no profile exists',
    () async {
      expect(await repository.readPreferredLanguage('ghost'), AppLanguage.ar);
    },
  );

  test('savePreferredLanguage persists the chosen language', () async {
    await seedProfile('user-1');

    await repository.savePreferredLanguage('user-1', AppLanguage.en);

    expect(await repository.readPreferredLanguage('user-1'), AppLanguage.en);
  });

  test('isOnboardingComplete stays false until marked complete', () async {
    await seedProfile('user-1');

    expect(await repository.isOnboardingComplete('user-1'), isFalse);
    await repository.markOnboardingComplete('user-1');
    expect(await repository.isOnboardingComplete('user-1'), isTrue);
  });

  test('markOnboardingComplete records the injected clock', () async {
    await seedProfile('user-1');

    await repository.markOnboardingComplete('user-1');

    final profile = await (database.select(
      database.localProfiles,
    )..where((r) => r.userId.equals('user-1'))).getSingle();
    expect(profile.onboardingCompletedAt?.toUtc(), now);
    expect(profile.localUpdatedAt.toUtc(), now);
  });
}
