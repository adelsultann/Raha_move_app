import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/profile/data/drift_profile_repository.dart';
import 'package:raha_move/features/profile/domain/profile_settings.dart';

void main() {
  late AppDatabase database;
  late DriftProfileRepository repository;
  final now = DateTime.utc(2026, 9, 6);

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
            localUpdatedAt: now,
          ),
        );
    await database
        .into(database.localUserPreferences)
        .insert(
          LocalUserPreferencesCompanion.insert(
            userId: 'user',
            experienceLevel: 'beginner',
            localUpdatedAt: now,
          ),
        );
    for (final mapping in const {
      'seated': '00000000-0000-4000-8000-000000000001',
      'standing': '00000000-0000-4000-8000-000000000002',
    }.entries) {
      await database
          .into(database.localIdMappings)
          .insert(
            LocalIdMappingsCompanion.insert(
              kind: RemoteIdMappingKind.taxonomy,
              localId: mapping.key,
              remoteId: mapping.value,
            ),
          );
    }
    repository = DriftProfileRepository(database, clock: () => now);
  });
  tearDown(() => database.close());

  test(
    'persists settings and independent telemetry consents locally offline',
    () async {
      await repository.save(
        'user',
        ProfileSettings(
          language: AppLanguage.en,
          weeklyGoalDays: 5,
          permittedPositions: const {'seated', 'standing'},
          soundEnabled: false,
          vibrationEnabled: true,
          wifiOnlyDownloads: false,
          reminderInterest: true,
          analyticsEnabled: true,
          crashReportingEnabled: false,
        ),
      );
      final restored = await repository.read('user');
      expect(restored.language, AppLanguage.en);
      expect(restored.weeklyGoalDays, 5);
      expect(restored.permittedPositions, {'seated', 'standing'});
      expect(restored.analyticsEnabled, isTrue);
      expect(restored.crashReportingEnabled, isFalse);
      final profile = await database.select(database.localProfiles).getSingle();
      expect(profile.syncState, SyncState.pendingUpdate);
      final outbox = await database.select(database.syncOutbox).getSingle();
      expect(outbox.kind, WireOperationKind.preferenceUpsert);
      expect(outbox.payloadJson, contains('preferences_v1'));
      expect(outbox.payloadJson, contains('analytics_consent'));
    },
  );

  test(
    'parks offline preference sync until a position UUID mapping arrives',
    () async {
      await repository.save(
        'user',
        ProfileSettings(
          language: AppLanguage.ar,
          weeklyGoalDays: 3,
          permittedPositions: const {'floor'},
          soundEnabled: true,
          vibrationEnabled: true,
          wifiOnlyDownloads: true,
          reminderInterest: false,
          analyticsEnabled: false,
          crashReportingEnabled: false,
        ),
      );
      var outbox = await database.select(database.syncOutbox).getSingle();
      expect(outbox.status, OutboxStatus.rejected);
      expect(outbox.kind, WireOperationKind.preferenceUpsert);
      final profile = await database.select(database.localProfiles).getSingle();
      expect(profile.syncState, SyncState.failed);

      await database
          .into(database.localIdMappings)
          .insert(
            LocalIdMappingsCompanion.insert(
              kind: RemoteIdMappingKind.taxonomy,
              localId: 'floor',
              remoteId: '00000000-0000-4000-8000-000000000003',
            ),
          );
      final rebuilt = await LocalUserDataRepository(
        database,
        activeUserId: 'user',
        clock: () => now,
      ).rebuildOutboxOperation('profile_preferences', 'user');
      expect(rebuilt, isTrue);
      outbox = await database.select(database.syncOutbox).getSingle();
      expect(outbox.status, OutboxStatus.pending);
      expect(
        outbox.payloadJson,
        contains('00000000-0000-4000-8000-000000000003'),
      );
    },
  );
}
