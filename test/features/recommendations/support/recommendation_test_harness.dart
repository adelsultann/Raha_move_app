import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/check_in/data/drift_check_in_repository.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:raha_move/features/onboarding/application/onboarding_providers.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';

import '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakeOnboardingRepository;
import '../../exercise_library/data/release_fixture.dart';

export '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakeOnboardingRepository;

final _now = DateTime.utc(2026, 8, 30, 12);

/// Seeds an in-memory database with the bundled starter-style catalog, a guest
/// profile, and one completed check-in, so the real recommendation providers
/// run end-to-end. Returns the open database (the caller must close it).
Future<AppDatabase> seedRecommendationDatabase({
  CheckInAnswers? checkInAnswers,
  String checkInId = 'check-in-1',
  String userId = 'guest-1',
}) async {
  final db = AppDatabase(NativeDatabase.memory());

  await ContentReleaseRepository(
    db,
    clock: () => _now,
  ).applyRelease(envelopeFor(minimalValidManifest()), appVersion: '1.0.0');

  // Seed the full check-in taxonomy so any check-in answer can be persisted;
  // the minimal manifest only seeds the keys its own content references.
  for (final (key, kind) in const [
    ('neck', 'body_area'),
    ('shoulders', 'body_area'),
    ('upper_back', 'body_area'),
    ('lower_back', 'body_area'),
    ('hips', 'body_area'),
    ('knees', 'body_area'),
    ('full_body', 'body_area'),
    ('ease_stiffness', 'goal'),
    ('move_more_freely', 'goal'),
    ('feel_energized', 'goal'),
    ('relax', 'goal'),
    ('desk_break', 'goal'),
    ('seated', 'position'),
    ('standing', 'position'),
    ('floor', 'position'),
  ]) {
    await db
        .into(db.localTaxonomies)
        .insertOnConflictUpdate(
          LocalTaxonomiesCompanion.insert(key: key, kind: kind),
        );
  }

  await db
      .into(db.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: userId,
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: _now,
        ),
      );

  await DriftCheckInRepository(db, clock: () => _now).save(
    userId: userId,
    checkInId: checkInId,
    startedAt: _now.subtract(const Duration(minutes: 1)),
    answers: checkInAnswers ?? matchingCheckIn(),
  );

  return db;
}

/// A check-in that the `minimalValidManifest` routine satisfies.
CheckInAnswers matchingCheckIn() => CheckInAnswers(
  bodyState: BodyState.stiff,
  goalKey: 'ease_stiffness',
  bodyAreaKeys: const {'neck'},
  availableMinutes: 5,
  positionKey: 'seated',
);

/// Builds a container wired with the given in-memory database, offline auth,
/// a stable guest identity, the active language, and an enabled analytics sink.
ProviderContainer buildRecommendationContainer(
  AppDatabase db, {
  AppLanguage language = AppLanguage.en,
}) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      appVersionProvider.overrideWithValue('1.0.0'),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      guestIdentityStoreProvider.overrideWithValue(FakeGuestIdentityStore()),
      onboardingRepositoryProvider.overrideWithValue(
        FakeOnboardingRepository()..language = language,
      ),
      analyticsServiceProvider.overrideWithValue(
        InMemoryAnalyticsService(enabled: true),
      ),
    ],
  );
}
