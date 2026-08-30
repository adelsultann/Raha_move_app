import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/preferences/data/drift_preferences_repository.dart';
import 'package:raha_move/features/preferences/domain/experience_level.dart';
import 'package:raha_move/features/preferences/domain/movement_position.dart';
import 'package:raha_move/features/preferences/domain/user_preferences.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seedProfile(database, 'user-1');
  });

  tearDown(() => database.close());

  DriftPreferencesRepository repository() =>
      DriftPreferencesRepository(database, clock: () => now);

  test('read returns null before any preferences are saved', () async {
    expect(await repository().read('user-1'), isNull);
  });

  test('save and read round-trip every preference field', () async {
    await repository().save(
      'user-1',
      UserPreferences(
        experienceLevel: ExperienceLevel.intermediate,
        preferredPositions: const {
          MovementPosition.seated,
          MovementPosition.floor,
        },
        weeklyGoalDays: 5,
        reminderInterest: true,
      ),
    );

    final read = await repository().read('user-1');
    expect(read, isNotNull);
    expect(read!.experienceLevel, ExperienceLevel.intermediate);
    expect(read.preferredPositions, {
      MovementPosition.seated,
      MovementPosition.floor,
    });
    expect(read.weeklyGoalDays, 5);
    expect(read.reminderInterest, isTrue);
  });

  test('empty preferred positions round-trip as "any position"', () async {
    await repository().save(
      'user-1',
      const UserPreferences(
        experienceLevel: ExperienceLevel.beginner,
        weeklyGoalDays: 3,
      ),
    );

    final read = await repository().read('user-1');
    expect(read!.preferredPositions, isEmpty);
  });

  test('weekly goal is persisted on the profile row', () async {
    await repository().save(
      'user-1',
      const UserPreferences(
        experienceLevel: ExperienceLevel.advanced,
        weeklyGoalDays: 6,
      ),
    );

    final profile = await (database.select(
      database.localProfiles,
    )..where((row) => row.userId.equals('user-1'))).getSingle();
    expect(profile.weeklyGoalDays, 6);
  });

  test('save marks both rows pending update for future sync', () async {
    await repository().save(
      'user-1',
      const UserPreferences(
        experienceLevel: ExperienceLevel.beginner,
        weeklyGoalDays: 4,
      ),
    );

    final prefs = await (database.select(
      database.localUserPreferences,
    )..where((row) => row.userId.equals('user-1'))).getSingle();
    final profile = await (database.select(
      database.localProfiles,
    )..where((row) => row.userId.equals('user-1'))).getSingle();

    expect(prefs.syncState, SyncState.pendingUpdate);
    expect(profile.syncState, SyncState.pendingUpdate);
  });

  test('positions are stored as a stable sorted key list', () async {
    await repository().save(
      'user-1',
      const UserPreferences(
        experienceLevel: ExperienceLevel.beginner,
        preferredPositions: {MovementPosition.floor, MovementPosition.seated},
        weeklyGoalDays: 3,
      ),
    );

    final prefs = await (database.select(
      database.localUserPreferences,
    )..where((row) => row.userId.equals('user-1'))).getSingle();
    expect(prefs.preferredPositionsJson, '["floor","seated"]');
  });
}

Future<void> _seedProfile(AppDatabase database, String userId) async {
  final now = DateTime.utc(2026, 8, 30, 12);
  await database
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
}
