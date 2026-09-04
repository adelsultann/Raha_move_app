import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/explore/data/drift_explore_repository.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';

import '../domain/saved_routine.dart';
import '../domain/saved_routines_repository.dart';

/// Drift implementation that delegates all mutations to the existing atomic
/// local-user-data/outbox boundary.
final class DriftSavedRoutinesRepository implements SavedRoutinesRepository {
  DriftSavedRoutinesRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _explore = DriftExploreRepository(_database);

  final AppDatabase _database;
  final DateTime Function() _clock;
  final DriftExploreRepository _explore;

  @override
  Future<bool> isSaved({
    required String userId,
    required String routineId,
  }) async {
    final row =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) => r.userId.equals(userId) & r.routineId.equals(routineId),
            ))
            .getSingleOrNull();
    return row != null && row.deletedAt == null;
  }

  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) async {
    final rows =
        await (_database.select(_database.localSavedRoutines)
              ..where((r) => r.userId.equals(userId) & r.deletedAt.isNull())
              ..orderBy([(r) => OrderingTerm.desc(r.savedAt)]))
            .get();
    final result = <SavedRoutine>[];
    for (final row in rows) {
      final routine = await (_database.select(
        _database.localRoutines,
      )..where((r) => r.id.equals(row.routineId))).getSingleOrNull();
      final title = await _title(row.routineId, locale);
      final details = routine == null
          ? null
          : await _explore.details(row.routineId, locale);
      result.add(
        SavedRoutine(
          routineId: row.routineId,
          title: title,
          isPlayable: details?.eligibility is RoutineStartAllowed,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> save({required String userId, required String routineId}) async {
    final routine = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.id.equals(routineId))).getSingleOrNull();
    if (routine == null ||
        routine.status != 'published' ||
        routine.accessTier != 'free') {
      throw StateError('Only published free routines can be saved.');
    }
    final existing = await isSaved(userId: userId, routineId: routineId);
    if (existing) return;
    final now = _clock().toUtc();
    await LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveSavedRoutine(
      savedRoutine: LocalSavedRoutinesCompanion.insert(
        userId: userId,
        routineId: routineId,
        savedAt: now,
        // `insertOnConflictUpdate` preserves absent fields. A re-save after an
        // offline tombstone must therefore explicitly clear this column.
        deletedAt: const Value(null),
        localUpdatedAt: now,
      ),
    );
  }

  @override
  Future<void> unsave({
    required String userId,
    required String routineId,
  }) async {
    final existing =
        await (_database.select(_database.localSavedRoutines)..where(
              (r) => r.userId.equals(userId) & r.routineId.equals(routineId),
            ))
            .getSingleOrNull();
    if (existing == null || existing.deletedAt != null) return;
    final now = _clock().toUtc();
    await LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveSavedRoutine(
      savedRoutine: LocalSavedRoutinesCompanion.insert(
        userId: userId,
        routineId: routineId,
        savedAt: existing.savedAt,
        deletedAt: Value(now),
        localUpdatedAt: now,
      ),
    );
  }

  Future<String> _title(String routineId, String locale) async {
    final translations = await (_database.select(
      _database.localRoutineTranslations,
    )..where((r) => r.routineId.equals(routineId))).get();
    return translations
            .where((translation) => translation.locale == locale)
            .map((translation) => translation.name)
            .firstOrNull ??
        translations
            .where((translation) => translation.locale == 'en')
            .map((translation) => translation.name)
            .firstOrNull ??
        routineId;
  }
}
