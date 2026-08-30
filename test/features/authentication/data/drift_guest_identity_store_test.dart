import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/authentication/data/drift_guest_identity_store.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  late AppDatabase database;
  late DriftGuestIdentityStore store;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftGuestIdentityStore(
      database,
      uuidGenerator: _uuidSequence(['guest-1', 'guest-2', 'supabase-1']),
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test('guest id is stable across restarts and store instances', () async {
    final first = await store.currentOrCreateGuestId();
    expect(first, 'guest-1');
    expect(await store.currentLocalUserId(), 'guest-1');

    // A fresh store over the same database reads the persisted identity.
    final reopened = DriftGuestIdentityStore(
      database,
      uuidGenerator: _uuidSequence(['should-not-be-used']),
      clock: () => now,
    );
    expect(await reopened.currentOrCreateGuestId(), 'guest-1');
  });

  test('ensureProfile creates safe defaults and is idempotent', () async {
    await store.ensureProfile('guest-1');
    await store.ensureProfile('guest-1');

    final profile = await (database.select(
      database.localProfiles,
    )..where((r) => r.userId.equals('guest-1'))).getSingle();
    final preferences = await (database.select(
      database.localUserPreferences,
    )..where((r) => r.userId.equals('guest-1'))).getSingle();

    expect(profile.preferredLocale, 'ar');
    expect(profile.timezone, 'Asia/Riyadh');
    expect(profile.weeklyGoalDays, 3);
    expect(profile.localUpdatedAt, isNotNull);
    expect(preferences.experienceLevel, 'beginner');
    expect(await database.select(database.localProfiles).get(), hasLength(1));
  });

  test('re-key moves data across every user-owned table, preserving other columns, '
      'and is idempotent', () async {
    await _seedCatalog(database, now);
    await _seedUserData(database, 'guest-1', now);
    await _seedMediaCache(database, now);
    await store.currentOrCreateGuestId(); // establishes the 'guest-1' identity

    await store.linkGuestToSupabaseUid(
      guestId: 'guest-1',
      supabaseUid: 'supabase-1',
    );
    // Idempotent second pass (no rows still owned by the old id).
    await store.linkGuestToSupabaseUid(
      guestId: 'guest-1',
      supabaseUid: 'supabase-1',
    );

    // Parent profile moved with its non-identity columns preserved.
    final profiles = await (database.select(
      database.localProfiles,
    )..where((r) => r.userId.equals('supabase-1'))).get();
    expect(profiles, hasLength(1));
    expect(profiles.single.preferredLocale, 'ar');
    expect(profiles.single.weeklyGoalDays, 4);
    expect(profiles.single.timezone, 'Asia/Riyadh');
    expect(profiles.single.onboardingCompletedAt?.toUtc(), now);

    final preferences = await (database.select(
      database.localUserPreferences,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(preferences.experienceLevel, 'intermediate');
    expect(preferences.soundEnabled, isFalse);
    expect(preferences.vibrationEnabled, isFalse);

    final reminder = await (database.select(
      database.localReminderSchedules,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(reminder.id, 'reminder-1-guest-1');
    expect(reminder.localTime, '08:30');
    expect(reminder.daysOfWeekJson, '[1,3,5]');

    final position = await (database.select(
      database.localPreferredPositions,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(position.positionKey, 'seated');
    expect(position.isPermitted, isFalse);

    final checkIn = await (database.select(
      database.localCheckIns,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(checkIn.bodyState, 'stiff');
    expect(checkIn.syncState, SyncState.synced);

    final recommendation = await (database.select(
      database.localRecommendations,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(recommendation.score, 42);
    expect(recommendation.reasonCodesJson, '["a","b"]');

    final session = await (database.select(
      database.localRoutineSessions,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(session.status, 'completed');
    expect(session.actualDurationSeconds, 50);
    expect(session.completionPolicyVersion, 'mvp_v1');

    final feedback = await (database.select(
      database.localSessionFeedback,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(feedback.rating, 'little_better');

    final saved = await (database.select(
      database.localSavedRoutines,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(saved.routineId, 'routine-1');
    expect(saved.savedAt.toUtc(), now);

    final projection = await (database.select(
      database.localProgressProjections,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(projection.projectionType, 'weekly_summary');
    expect(projection.payloadJson, '{"minutes":30}');

    final syncState = await (database.select(
      database.localSyncState,
    )..where((r) => r.userId.equals('supabase-1'))).getSingle();
    expect(syncState.pullCursor, 42);

    final outbox = await (database.select(
      database.syncOutbox,
    )..where((r) => r.ownerUserId.equals('supabase-1'))).getSingle();
    expect(outbox.entityId, 'checkin-1');
    expect(outbox.payloadJson, '{"id":"checkin-1"}');

    // No rows remain under the old guest id.
    expect(
      await (database.select(
        database.localProfiles,
      )..where((r) => r.userId.equals('guest-1'))).get(),
      isEmpty,
    );
    expect(
      await (database.select(
        database.localCheckIns,
      )..where((r) => r.userId.equals('guest-1'))).get(),
      isEmpty,
    );
    expect(
      await (database.select(
        database.syncOutbox,
      )..where((r) => r.ownerUserId.equals('guest-1'))).get(),
      isEmpty,
    );

    // Identity row now points at the Supabase uid.
    expect(await store.currentLocalUserId(), 'supabase-1');

    // Media cache entries are never re-keyed (owner id is always a Supabase
    // uid, never a guest UUID).
    final cacheEntries = await database
        .select(database.localMediaCacheEntries)
        .get();
    expect(cacheEntries.single.ownerId, 'media-owner-1');
  });

  test(
    'cross-account isolation: user A rows are not returned for user B',
    () async {
      await _seedCatalog(database, now);
      await _seedUserData(database, 'guest-a', now);
      await _seedUserData(database, 'guest-b', now, checkInId: 'checkin-b');

      await store.linkGuestToSupabaseUid(
        guestId: 'guest-a',
        supabaseUid: 'supabase-a',
      );

      final aCheckIns = await (database.select(
        database.localCheckIns,
      )..where((r) => r.userId.equals('supabase-a'))).get();
      final bCheckIns = await (database.select(
        database.localCheckIns,
      )..where((r) => r.userId.equals('guest-b'))).get();

      expect(aCheckIns.single.id, 'checkin-1');
      expect(bCheckIns.single.id, 'checkin-b');
      expect(
        await (database.select(
          database.localCheckIns,
        )..where((r) => r.userId.equals('guest-a'))).get(),
        isEmpty,
      );
    },
  );

  test('link is a no-op when ids are already equal', () async {
    await store.currentOrCreateGuestId(); // guest-1
    await store.linkGuestToSupabaseUid(
      guestId: 'guest-1',
      supabaseUid: 'guest-1',
    );
    expect(await store.currentLocalUserId(), 'guest-1');
  });

  test('resetForSignOut mints a fresh id and its profile', () async {
    await store.currentOrCreateGuestId(); // guest-1
    await store.ensureProfile('guest-1');

    await store.resetForSignOut();

    final freshId = await store.currentLocalUserId();
    expect(freshId, 'guest-2');
    expect(freshId, isNot('guest-1'));
    expect(
      await (database.select(
        database.localProfiles,
      )..where((r) => r.userId.equals('guest-2'))).getSingleOrNull(),
      isNotNull,
    );
  });

  test(
    'activateAccount switches identity without merging another user',
    () async {
      await _seedCatalog(database, now);
      await _seedUserData(database, 'guest-1', now);

      await store.activateAccount('existing-account');

      expect(await store.currentLocalUserId(), 'existing-account');
      // Guest data is NOT re-keyed into the existing account.
      expect(
        await (database.select(
          database.localCheckIns,
        )..where((r) => r.userId.equals('existing-account'))).get(),
        isEmpty,
      );
      expect(
        await (database.select(
          database.localCheckIns,
        )..where((r) => r.userId.equals('guest-1'))).get(),
        hasLength(1),
      );
      // The existing account got a fresh profile.
      expect(
        await (database.select(
          database.localProfiles,
        )..where((r) => r.userId.equals('existing-account'))).getSingleOrNull(),
        isNotNull,
      );
    },
  );
}

String Function() _uuidSequence(List<String> values) {
  var index = 0;
  return () => values[index < values.length ? index++ : values.length - 1];
}

Future<void> _seedCatalog(AppDatabase database, DateTime now) async {
  await database
      .into(database.localTaxonomies)
      .insert(
        LocalTaxonomiesCompanion.insert(key: 'ease_stiffness', kind: 'goal'),
      );
  await database
      .into(database.localTaxonomies)
      .insert(LocalTaxonomiesCompanion.insert(key: 'seated', kind: 'position'));
  await database
      .into(database.localExercises)
      .insert(
        LocalExercisesCompanion.insert(
          id: 'exercise-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          safetyApproved: true,
          updatedAt: now,
        ),
      );
  await database
      .into(database.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 60,
          version: 1,
          updatedAt: now,
        ),
      );
  await database
      .into(database.localRoutineSteps)
      .insert(
        LocalRoutineStepsCompanion.insert(
          id: 'step-1',
          routineId: 'routine-1',
          exerciseId: 'exercise-1',
          position: 1,
          durationSeconds: 60,
        ),
      );
}

Future<void> _seedUserData(
  AppDatabase database,
  String userId,
  DateTime now, {
  String checkInId = 'checkin-1',
}) async {
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: userId,
          preferredLocale: 'ar',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 4,
          onboardingCompletedAt: Value(now),
          syncState: const Value(SyncState.synced),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localUserPreferences)
      .insert(
        LocalUserPreferencesCompanion.insert(
          userId: userId,
          experienceLevel: 'intermediate',
          soundEnabled: const Value(false),
          vibrationEnabled: const Value(false),
          downloadOnWifiOnly: const Value(false),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localReminderSchedules)
      .insert(
        LocalReminderSchedulesCompanion.insert(
          id: 'reminder-1-$userId',
          userId: userId,
          localTime: '08:30',
          daysOfWeekJson: '[1,3,5]',
          timezone: 'Asia/Riyadh',
          enabled: const Value(false),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localPreferredPositions)
      .insert(
        LocalPreferredPositionsCompanion.insert(
          userId: userId,
          positionKey: 'seated',
          isPermitted: const Value(false),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localCheckIns)
      .insert(
        LocalCheckInsCompanion.insert(
          id: checkInId,
          userId: userId,
          bodyState: 'stiff',
          goalKey: 'ease_stiffness',
          availableMinutes: 10,
          positionKey: const Value('seated'),
          startedAt: now,
          completedAt: Value(now),
          syncState: const Value(SyncState.synced),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localRecommendations)
      .insert(
        LocalRecommendationsCompanion.insert(
          id: 'rec-1-$userId',
          userId: userId,
          checkInId: checkInId,
          routineId: 'routine-1',
          engineVersion: 'rules_v1',
          rank: 0,
          score: 42,
          reasonCodesJson: '["a","b"]',
          shownAt: now,
          acceptedAt: Value(now),
          syncState: const Value(SyncState.synced),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localRoutineSessions)
      .insert(
        LocalRoutineSessionsCompanion.insert(
          id: 'session-1-$userId',
          userId: userId,
          routineId: 'routine-1',
          routineVersion: 1,
          status: 'completed',
          startedAt: now,
          completedAt: Value(now),
          targetDurationSeconds: 60,
          actualDurationSeconds: 50,
          totalSteps: 1,
          stepsCompleted: const Value(1),
          completionPolicyVersion: 'mvp_v1',
          source: 'recommendation',
          syncState: const Value(SyncState.synced),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localSessionFeedback)
      .insert(
        LocalSessionFeedbackCompanion.insert(
          sessionId: 'session-1-$userId',
          userId: userId,
          rating: 'little_better',
          createdAt: now,
          syncState: const Value(SyncState.synced),
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localSavedRoutines)
      .insert(
        LocalSavedRoutinesCompanion.insert(
          userId: userId,
          routineId: 'routine-1',
          savedAt: now,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localProgressProjections)
      .insert(
        LocalProgressProjectionsCompanion.insert(
          userId: userId,
          projectionType: 'weekly_summary',
          payloadJson: '{"minutes":30}',
          serverUpdatedAt: now,
        ),
      );
  await database
      .into(database.localSyncState)
      .insert(
        LocalSyncStateCompanion.insert(
          userId: userId,
          pullCursor: const Value(42),
        ),
      );
  await database
      .into(database.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          operationId: 'op-$userId',
          kind: 'check_in_upsert',
          entityType: 'check_in',
          entityId: checkInId,
          ownerUserId: userId,
          payloadJson: '{"id":"$checkInId"}',
          nextAttemptAt: now,
          createdAt: now,
        ),
      );
}

Future<void> _seedMediaCache(AppDatabase database, DateTime now) async {
  await database
      .into(database.localMediaAssets)
      .insert(
        LocalMediaAssetsCompanion.insert(
          id: 'media-1',
          exerciseId: 'exercise-1',
          mediaType: 'video',
          deliveryReference: 'delivery/exercise-1/v1.mp4',
          mimeType: 'video/mp4',
          checksumSha256: 'a' * 64,
          status: 'published',
          updatedAt: now,
        ),
      );
  await database
      .into(database.localMediaCacheEntries)
      .insert(
        LocalMediaCacheEntriesCompanion.insert(
          ownerId: 'media-owner-1',
          mediaId: 'media-1',
          verifiedLocalPath: '/cache/media-1.mp4',
          mediaVersion: 'release-1',
          checksumSha256: 'a' * 64,
          byteSize: 10,
          cacheState: 'verified',
          lastAccessedAt: now,
          verifiedAt: now,
        ),
      );
}
