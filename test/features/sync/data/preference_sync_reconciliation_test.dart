import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/sync/data/drift_sync_outbox_repository.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';

void main() {
  late AppDatabase database;
  late DriftSyncOutboxRepository outbox;
  final serverTime = DateTime.utc(2026, 9, 7, 10);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            userId: 'user',
            preferredLocale: 'ar',
            timezone: 'Asia/Riyadh',
            weeklyGoalDays: 3,
            localUpdatedAt: serverTime,
          ),
        );
    await database
        .into(database.localUserPreferences)
        .insert(
          LocalUserPreferencesCompanion.insert(
            userId: 'user',
            experienceLevel: 'beginner',
            localUpdatedAt: serverTime,
          ),
        );
    await database
        .into(database.localIdMappings)
        .insert(
          LocalIdMappingsCompanion.insert(
            kind: RemoteIdMappingKind.taxonomy,
            localId: 'seated',
            remoteId: '00000000-0000-4000-8000-000000000001',
          ),
        );
    outbox = DriftSyncOutboxRepository(
      database,
      activeUserId: 'user',
      clock: () => serverTime,
    );
  });
  tearDown(() => database.close());

  test(
    'applies authoritative LWW preference projection through UUID mapping',
    () async {
      await outbox.storeProjections([_projection(serverTime)]);
      final profile = await database.select(database.localProfiles).getSingle();
      final preferences = await database
          .select(database.localUserPreferences)
          .getSingle();
      expect(profile.preferredLocale, 'en');
      expect(profile.weeklyGoalDays, 5);
      expect(preferences.preferredPositionsJson, jsonEncode(['seated']));
      expect(preferences.experienceLevel, 'intermediate');
      expect(preferences.soundEnabled, isFalse);
      expect(preferences.reminderInterest, isTrue);
      final consent = await database
          .select(database.environmentEntries)
          .getSingle();
      expect(jsonDecode(consent.value)['analytics'], isTrue);
    },
  );

  test(
    'retains newer pending local preference write during reconciliation',
    () async {
      await database
          .into(database.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              operationId: '00000000-0000-4000-8000-000000000100',
              kind: WireOperationKind.preferenceUpsert,
              entityType: 'profile_preferences',
              entityId: 'user',
              ownerUserId: 'user',
              payloadJson: '{}',
              nextAttemptAt: serverTime,
              createdAt: serverTime,
            ),
          );
      await outbox.storeProjections([_projection(serverTime)]);
      final profile = await database.select(database.localProfiles).getSingle();
      expect(profile.preferredLocale, 'ar');
    },
  );
}

SyncProjection _projection(DateTime at) => SyncProjection(
  projectionType: 'preferences',
  serverUpdatedAt: at,
  payloadJson: jsonEncode({
    'contract_version': 'preferences_v1',
    'preferred_locale': 'en',
    'weekly_goal_days': 5,
    'experience_level': 'intermediate',
    'position_ids': ['00000000-0000-4000-8000-000000000001'],
    'sound_enabled': false,
    'vibration_enabled': true,
    'download_on_wifi_only': false,
    'reminders_enabled': true,
    'analytics_consent': true,
    'crash_reporting_consent': false,
    'operation_at': at.toIso8601String(),
  }),
);
