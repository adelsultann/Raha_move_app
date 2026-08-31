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
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakeOnboardingRepository;
import '../../exercise_library/data/release_fixture.dart';

export '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakeOnboardingRepository;

final _now = DateTime.utc(2026, 8, 30, 12);

/// Seeds an in-memory database with a catalog (bundled starter-style by
/// default), a guest profile, and one completed check-in, so the real
/// recommendation providers run end-to-end. Returns the open database (the
/// caller must close it).
Future<AppDatabase> seedRecommendationDatabase({
  CheckInAnswers? checkInAnswers,
  String checkInId = 'check-in-1',
  String userId = 'guest-1',
  Map<String, dynamic>? manifest,
}) async {
  final db = AppDatabase(NativeDatabase.memory());

  await ContentReleaseRepository(db, clock: () => _now).applyRelease(
    envelopeFor(manifest ?? minimalValidManifest()),
    appVersion: '1.0.0',
  );

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

/// A three-routine catalog for the rejection loop: two beginner and one
/// intermediate routine, all matching the check-in so alternatives exist.
/// Routine ids are `raha_rt_000001` (beginner), `raha_rt_000002` (beginner),
/// and `raha_rt_000003` (intermediate).
Map<String, dynamic> multiRoutineManifest() {
  const exerciseUuid = '01000000-0000-0000-0000-000000000001';
  const mediaUuid = '02000000-0000-0000-0000-000000000001';
  const bodyAreaUuid = '41000000-0000-0000-0000-000000000001';
  const goalUuid = '42000000-0000-0000-0000-000000000001';
  const positionUuid = '43000000-0000-0000-0000-000000000001';
  const equipmentUuid = '44000000-0000-0000-0000-000000000001';
  const contextUuid = '45000000-0000-0000-0000-000000000001';

  final routines = <Map<String, dynamic>>[];
  final routineTranslations = <Map<String, dynamic>>[];
  final routineSteps = <Map<String, dynamic>>[];
  final routineBodyAreas = <Map<String, dynamic>>[];
  final routineGoals = <Map<String, dynamic>>[];
  final routinePositions = <Map<String, dynamic>>[];
  final routineContexts = <Map<String, dynamic>>[];
  final routineEquipment = <Map<String, dynamic>>[];

  final specs = <(String, String, String, String)>[
    (
      'raha_rt_000001',
      'beginner',
      '03000000-0000-0000-0000-000000000001',
      '04000000-0000-0000-0000-000000000001',
    ),
    (
      'raha_rt_000002',
      'beginner',
      '03000000-0000-0000-0000-000000000002',
      '04000000-0000-0000-0000-000000000002',
    ),
    (
      'raha_rt_000003',
      'intermediate',
      '03000000-0000-0000-0000-000000000003',
      '04000000-0000-0000-0000-000000000003',
    ),
  ];
  for (final (publicId, difficulty, routineUuid, stepUuid) in specs) {
    routines.add({
      'id': routineUuid,
      'public_id': publicId,
      'status': 'published',
      'access_tier': 'free',
      'difficulty': difficulty,
      'safety_approved': true,
      'estimated_duration_seconds': 300,
      'version': 1,
      'updated_at': '2026-08-29T00:00:00Z',
    });
    routineTranslations.addAll([
      {
        'routine_id': routineUuid,
        'locale': 'en',
        'name': 'Routine $publicId',
        'summary': 'A short routine.',
      },
      {
        'routine_id': routineUuid,
        'locale': 'ar',
        'name': 'روتين $publicId',
        'summary': 'روتين قصير.',
      },
    ]);
    routineSteps.add({
      'id': stepUuid,
      'routine_id': routineUuid,
      'exercise_id': exerciseUuid,
      'position': 1,
      'duration_seconds': 300,
      'rest_after_seconds': 0,
      'is_optional': false,
    });
    routineBodyAreas.add({
      'routine_id': routineUuid,
      'body_area_id': bodyAreaUuid,
      'relevance_weight': 1.0,
    });
    routineGoals.add({
      'routine_id': routineUuid,
      'goal_id': goalUuid,
      'relevance_weight': 1.0,
    });
    routinePositions.add({
      'routine_id': routineUuid,
      'position_id': positionUuid,
    });
    routineContexts.add({'routine_id': routineUuid, 'context_id': contextUuid});
    routineEquipment.add({
      'routine_id': routineUuid,
      'equipment_id': equipmentUuid,
    });
  }

  return {
    'contract_version': 'raha-content-release-v1',
    'release': {
      'id': '1',
      'version': 'release-1',
      'published_at': '2026-08-29T00:00:00Z',
      'minimum_app_version': '1.0.0',
    },
    'exercises': [
      {
        'id': exerciseUuid,
        'public_id': 'raha_ex_000001',
        'status': 'published',
        'access_tier': 'free',
        'difficulty': 'beginner',
        'safety_approved': true,
        'updated_at': '2026-08-29T00:00:00Z',
      },
    ],
    'exercise_translations': [
      {
        'exercise_id': exerciseUuid,
        'locale': 'en',
        'name': 'Seated neck release',
        'description': 'A gentle seated neck stretch.',
      },
      {
        'exercise_id': exerciseUuid,
        'locale': 'ar',
        'name': 'تحرير الرقبة',
        'description': 'تمدد لطيف للرقبة.',
      },
    ],
    'media_assets': [
      {
        'id': mediaUuid,
        'exercise_id': exerciseUuid,
        'delivery_reference': '0a000000-0000-0000-0000-000000000001',
        'status': 'published',
        'media_type': 'video',
        'mime_type': 'video/mp4',
        'width': 720,
        'height': 720,
        'duration_ms': 30000,
        'checksum_sha256':
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'is_preferred': true,
        'updated_at': '2026-08-29T00:00:00Z',
      },
    ],
    'routines': routines,
    'routine_translations': routineTranslations,
    'routine_steps': routineSteps,
    'body_areas': [
      {'id': bodyAreaUuid, 'key': 'neck', 'sort_order': 1, 'active': true},
    ],
    'body_area_translations': [
      {'body_area_id': bodyAreaUuid, 'locale': 'en', 'name': 'Neck'},
      {'body_area_id': bodyAreaUuid, 'locale': 'ar', 'name': 'الرقبة'},
    ],
    'goals': [
      {
        'id': goalUuid,
        'key': 'ease_stiffness',
        'sort_order': 1,
        'active': true,
      },
    ],
    'goal_translations': [
      {'goal_id': goalUuid, 'locale': 'en', 'name': 'Ease stiffness'},
      {'goal_id': goalUuid, 'locale': 'ar', 'name': 'تخفيف التيبس'},
    ],
    'movement_positions': [
      {'id': positionUuid, 'key': 'seated', 'sort_order': 1, 'active': true},
    ],
    'movement_position_translations': [
      {'position_id': positionUuid, 'locale': 'en', 'name': 'Seated'},
      {'position_id': positionUuid, 'locale': 'ar', 'name': 'جلوس'},
    ],
    'equipment': [
      {
        'id': equipmentUuid,
        'key': 'body_weight',
        'sort_order': 1,
        'active': true,
      },
    ],
    'equipment_translations': [
      {'equipment_id': equipmentUuid, 'locale': 'en', 'name': 'Body weight'},
      {'equipment_id': equipmentUuid, 'locale': 'ar', 'name': 'وزن الجسم'},
    ],
    'routine_contexts': [
      {
        'id': contextUuid,
        'key': 'everyday_mobility',
        'sort_order': 1,
        'active': true,
      },
    ],
    'routine_context_translations': [
      {'context_id': contextUuid, 'locale': 'en', 'name': 'Everyday mobility'},
      {'context_id': contextUuid, 'locale': 'ar', 'name': 'حركة يومية'},
    ],
    'tags': <Object>[],
    'tag_translations': <Object>[],
    'exercise_body_areas': [
      {
        'exercise_id': exerciseUuid,
        'body_area_id': bodyAreaUuid,
        'relevance_weight': 1.0,
      },
    ],
    'exercise_positions': [
      {'exercise_id': exerciseUuid, 'position_id': positionUuid},
    ],
    'exercise_equipment': [
      {'exercise_id': exerciseUuid, 'equipment_id': equipmentUuid},
    ],
    'exercise_goals': [
      {'exercise_id': exerciseUuid, 'goal_id': goalUuid},
    ],
    'exercise_tags': <Object>[],
    'routine_body_areas': routineBodyAreas,
    'routine_goals': routineGoals,
    'routine_positions': routinePositions,
    'routine_context_memberships': routineContexts,
    'routine_equipment': routineEquipment,
    'tombstones': <Object>[],
  };
}

/// Builds a container wired with the given in-memory database, offline auth,
/// a stable guest identity, the active language, and an enabled analytics sink.
ProviderContainer buildRecommendationContainer(
  AppDatabase db, {
  AppLanguage language = AppLanguage.en,
  List<Override> extraOverrides = const [],
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
      ...extraOverrides,
    ],
  );
}
