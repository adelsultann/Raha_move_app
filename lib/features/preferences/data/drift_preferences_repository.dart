import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/experience_level.dart';
import '../domain/movement_position.dart';
import '../domain/preferences_repository.dart';
import '../domain/user_preferences.dart';

/// Drift-backed [PreferencesRepository].
///
/// Reads and writes `local_user_preferences` (experience level, reminder
/// interest, preferred positions) and `local_profiles.weekly_goal_days` in one
/// transaction so a save is atomic and available offline immediately. The
/// profile row is expected to already exist (created by the guest identity
/// store at auth initialization).
final class DriftPreferencesRepository implements PreferencesRepository {
  DriftPreferencesRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<UserPreferences?> read(String userId) async {
    final prefs = await (_database.select(
      _database.localUserPreferences,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    if (prefs == null) return null;

    final profile = await (_database.select(
      _database.localProfiles,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();

    return UserPreferences(
      experienceLevel: ExperienceLevel.fromCode(prefs.experienceLevel),
      preferredPositions: _decodePositions(prefs.preferredPositionsJson),
      weeklyGoalDays: profile?.weeklyGoalDays ?? 3,
      reminderInterest: prefs.reminderInterest,
    );
  }

  @override
  Future<void> save(String userId, UserPreferences preferences) {
    final now = _clock().toUtc();
    return _database.transaction(() async {
      await _database
          .into(_database.localUserPreferences)
          .insertOnConflictUpdate(
            LocalUserPreferencesCompanion.insert(
              userId: userId,
              experienceLevel: preferences.experienceLevel.code,
              reminderInterest: Value(preferences.reminderInterest),
              preferredPositionsJson: Value(
                _encodePositions(preferences.preferredPositions),
              ),
              localUpdatedAt: now,
            ).copyWith(
              syncState: const Value(SyncState.pendingUpdate),
              serverUpdatedAt: const Value(null),
              lastSyncError: const Value(null),
            ),
          );

      await (_database.update(
        _database.localProfiles,
      )..where((row) => row.userId.equals(userId))).write(
        LocalProfilesCompanion(
          weeklyGoalDays: Value(preferences.weeklyGoalDays),
          syncState: const Value(SyncState.pendingUpdate),
          localUpdatedAt: Value(now),
          lastSyncError: const Value(null),
        ),
      );
    });
  }

  static String _encodePositions(Set<MovementPosition> positions) {
    final keys = positions.map((position) => position.key).toList()..sort();
    return jsonEncode(keys);
  }

  static Set<MovementPosition> _decodePositions(String? source) {
    if (source == null || source.isEmpty) return const <MovementPosition>{};
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      return const <MovementPosition>{};
    }
    if (decoded is! List) return const <MovementPosition>{};
    final known = {
      for (final position in MovementPosition.values) position.key: position,
    };
    return <MovementPosition>{
      for (final value in decoded)
        if (value is String && known.containsKey(value)) known[value]!,
    };
  }
}
