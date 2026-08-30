import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/guest_identity_store.dart';

/// Drift-backed [GuestIdentityStore].
///
/// The single [LocalIdentity] row records the active local user id (a guest
/// UUID until it is re-keyed to the Supabase auth uid). The re-key moves every
/// user-owned child row, then the parent profile, then the identity row, inside
/// one transaction with deferred foreign-key checks so the identity column can
/// change without violating referential integrity.
final class DriftGuestIdentityStore implements GuestIdentityStore {
  DriftGuestIdentityStore(
    this._database, {
    String Function()? uuidGenerator,
    DateTime Function()? clock,
  }) : _uuidGenerator = uuidGenerator ?? generateUuidV4,
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final String Function() _uuidGenerator;
  final DateTime Function() _clock;

  static const int _identityRowId = 1;

  @override
  Future<String> currentOrCreateGuestId() async {
    final existing = await _identity();
    if (existing != null) return existing.userId;
    final id = _uuidGenerator();
    await _database
        .into(_database.localIdentity)
        .insert(LocalIdentityCompanion.insert(id: const Value(1), userId: id));
    return id;
  }

  @override
  Future<String> currentLocalUserId() async {
    final existing = await _identity();
    if (existing == null) {
      throw StateError('No local identity has been created yet');
    }
    return existing.userId;
  }

  Future<LocalIdentityData?> _identity() => (_database.select(
    _database.localIdentity,
  )..where((r) => r.id.equals(_identityRowId))).getSingleOrNull();

  @override
  Future<void> ensureProfile(String userId) => _database.transaction(() async {
    final now = _clock();
    final hasProfile =
        await (_database.select(
          _database.localProfiles,
        )..where((r) => r.userId.equals(userId))).getSingleOrNull() !=
        null;
    if (!hasProfile) {
      await _database
          .into(_database.localProfiles)
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
    final hasPreferences =
        await (_database.select(
          _database.localUserPreferences,
        )..where((r) => r.userId.equals(userId))).getSingleOrNull() !=
        null;
    if (!hasPreferences) {
      await _database
          .into(_database.localUserPreferences)
          .insert(
            LocalUserPreferencesCompanion.insert(
              userId: userId,
              experienceLevel: 'beginner',
              localUpdatedAt: now,
            ),
          );
    }
  });

  @override
  Future<void> linkGuestToSupabaseUid({
    required String guestId,
    required String supabaseUid,
  }) async {
    if (guestId == supabaseUid) return;
    await _database.transaction(() async {
      // Deferred FK checks let us re-key children before the parent profile.
      await _database.customStatement('PRAGMA defer_foreign_keys = ON');
      await _rekey('local_user_preferences', guestId, supabaseUid);
      await _rekey('local_reminder_schedules', guestId, supabaseUid);
      await _rekey('local_preferred_positions', guestId, supabaseUid);
      await _rekey('local_check_ins', guestId, supabaseUid);
      await _rekey('local_recommendations', guestId, supabaseUid);
      await _rekey('local_routine_sessions', guestId, supabaseUid);
      await _rekey('local_session_feedback', guestId, supabaseUid);
      await _rekey('local_saved_routines', guestId, supabaseUid);
      await _rekey('local_progress_projections', guestId, supabaseUid);
      await _rekey('local_sync_state', guestId, supabaseUid);
      await _rekey(
        'sync_outbox',
        guestId,
        supabaseUid,
        column: 'owner_user_id',
      );
      await _rekey('local_profiles', guestId, supabaseUid);
      await _rekeyIdentity(supabaseUid);
    });
  }

  @override
  Future<void> activateAccount(String accountId) async {
    await _database
        .into(_database.localIdentity)
        .insertOnConflictUpdate(
          LocalIdentityCompanion.insert(id: const Value(1), userId: accountId),
        );
    await ensureProfile(accountId);
  }

  @override
  Future<void> resetForSignOut() => activateAccount(_uuidGenerator());

  Future<void> _rekey(
    String table,
    String from,
    String to, {
    String column = 'user_id',
  }) {
    return _database.customUpdate(
      'UPDATE $table SET $column = ? WHERE $column = ?',
      variables: [Variable<String>(to), Variable<String>(from)],
    );
  }

  Future<void> _rekeyIdentity(String to) {
    return _database.customUpdate(
      'UPDATE local_identity SET user_id = ? WHERE id = ?',
      variables: [Variable<String>(to), Variable<int>(_identityRowId)],
    );
  }
}
