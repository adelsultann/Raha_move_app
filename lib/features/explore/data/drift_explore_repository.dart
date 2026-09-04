import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/data/drift_routine_presentation_repository.dart';

import '../domain/explore_models.dart';

/// Offline-only Explore projection. It deliberately has no remote client.
final class DriftExploreRepository implements ExploreRepository {
  DriftExploreRepository(this._database)
    : _presentations = DriftRoutinePresentationRepository(_database);

  final AppDatabase _database;
  final DriftRoutinePresentationRepository _presentations;

  @override
  Future<List<ExploreCategory>> categories(String locale) async {
    final routineIds = await _publishedRoutineIds();
    if (routineIds.isEmpty) return const [];
    final memberships = await (_database.select(
      _database.localRoutineTaxonomies,
    )..where((row) => row.routineId.isIn(routineIds))).get();
    final keys = memberships.map((row) => row.taxonomyKey).toSet();
    final taxonomies =
        await (_database.select(_database.localTaxonomies)
              ..where(
                (row) =>
                    row.key.isIn(keys) & row.kind.equals('routine_context'),
              )
              ..where((row) => row.isActive.equals(true))
              ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
            .get();
    return [
      for (final taxonomy in taxonomies)
        ExploreCategory(
          key: taxonomy.key,
          label: await _taxonomyLabel(taxonomy.key, locale),
        ),
    ];
  }

  @override
  Future<List<ExploreRoutineCard>> browse({
    required String locale,
    String? context,
    required ExploreFilters filters,
  }) async {
    final result = <ExploreRoutineCard>[];
    for (final routineId in await _publishedRoutineIds()) {
      final taxonomy = await _taxonomyKeys(routineId);
      if (context != null && !taxonomy.contains(context)) continue;
      final routine = await (_database.select(
        _database.localRoutines,
      )..where((row) => row.id.equals(routineId))).getSingle();
      if (!_matches(routine, taxonomy, filters)) continue;
      final presentation = await _presentations.load(routineId, locale);
      if (presentation == null || presentation.movements.isEmpty) continue;
      result.add(
        ExploreRoutineCard(
          routineId: routineId,
          name: presentation.name,
          summary: presentation.summary,
          durationSeconds: presentation.estimatedDurationSeconds,
          difficulty: presentation.difficulty,
          positions: presentation.positions,
          equipment: presentation.equipment,
          movementCount: presentation.movementCount,
        ),
      );
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  Future<ExploreRoutineDetails?> details(
    String routineId,
    String locale,
  ) async {
    final presentation = await _presentations.load(routineId, locale);
    if (presentation == null) return null;
    return ExploreRoutineDetails(
      presentation: presentation,
      eligibility: await _eligibility(routineId),
      equipmentLabels: {
        for (final key in presentation.equipment)
          key: await _taxonomyLabel(key, locale),
      },
    );
  }

  Future<RoutineStartEligibility> _eligibility(String routineId) async {
    final routine = await (_database.select(
      _database.localRoutines,
    )..where((row) => row.id.equals(routineId))).getSingleOrNull();
    if (routine == null || routine.status != 'published') {
      return const RoutineStartEligibility.blocked(RoutineStartBlock.retired);
    }
    // No entitlement projection is a denial. This remains fail-closed even if
    // a media asset happens to be cached.
    if (routine.accessTier != AccessTier.free.name) {
      return const RoutineStartEligibility.blocked(
        RoutineStartBlock.unauthorized,
      );
    }
    final steps =
        await (_database.select(_database.localRoutineSteps)..where(
              (row) =>
                  row.routineId.equals(routineId) &
                  row.status.equals('published'),
            ))
            .get();
    if (steps.isEmpty) {
      return const RoutineStartEligibility.blocked(
        RoutineStartBlock.unavailable,
      );
    }
    final exercises =
        await (_database.select(_database.localExercises)..where(
              (row) =>
                  row.id.isIn(steps.map((step) => step.exerciseId).toSet()),
            ))
            .get();
    if (exercises.length !=
            steps.map((step) => step.exerciseId).toSet().length ||
        exercises.any(
          (exercise) =>
              exercise.status != 'published' || !exercise.safetyApproved,
        )) {
      return const RoutineStartEligibility.blocked(
        RoutineStartBlock.incompatible,
      );
    }
    final exerciseIds = steps.map((step) => step.exerciseId).toSet();
    final media =
        await (_database.select(_database.localMediaAssets)..where(
              (row) =>
                  row.exerciseId.isIn(exerciseIds) &
                  row.status.equals('published'),
            ))
            .get();
    final playableExerciseIds = media
        .where(
          (asset) =>
              (asset.mediaType == 'video' || asset.mediaType == 'animation') &&
              asset.checksumSha256.isNotEmpty,
        )
        .map((asset) => asset.exerciseId)
        .toSet();
    if (!steps.every((step) => playableExerciseIds.contains(step.exerciseId))) {
      return const RoutineStartEligibility.blocked(
        RoutineStartBlock.unavailable,
      );
    }
    return const RoutineStartEligibility.allowed();
  }

  bool _matches(
    LocalRoutine routine,
    Set<String> taxonomy,
    ExploreFilters filters,
  ) {
    final durationMinutes = (routine.estimatedDurationSeconds / 60).ceil();
    if (filters.durationsMinutes.isNotEmpty &&
        !filters.durationsMinutes.contains(durationMinutes)) {
      return false;
    }
    final difficulty = DifficultyLevel.values
        .where((value) => value.name == routine.difficulty)
        .firstOrNull;
    // A malformed cached row must not prevent the rest of Explore rendering.
    if (difficulty == null) return false;
    if (filters.difficulties.isNotEmpty &&
        !filters.difficulties.contains(difficulty)) {
      return false;
    }
    bool containsAny(Set<String> selected, String kind) =>
        selected.isEmpty ||
        taxonomy.any(
          (key) => _kindByKey[key] == kind && selected.contains(key),
        );
    return containsAny(filters.bodyAreas, 'body_area') &&
        containsAny(filters.positions, 'position') &&
        containsAny(filters.equipment, 'equipment');
  }

  final Map<String, String> _kindByKey = {};

  Future<Set<String>> _taxonomyKeys(String routineId) async {
    final memberships = await (_database.select(
      _database.localRoutineTaxonomies,
    )..where((row) => row.routineId.equals(routineId))).get();
    final keys = memberships.map((row) => row.taxonomyKey).toSet();
    if (keys.isNotEmpty) {
      final taxonomies = await (_database.select(
        _database.localTaxonomies,
      )..where((row) => row.key.isIn(keys))).get();
      _kindByKey.addAll({for (final row in taxonomies) row.key: row.kind});
    }
    return keys;
  }

  Future<List<String>> _publishedRoutineIds() async =>
      (await (_database.select(
            _database.localRoutines,
          )..where((row) => row.status.equals('published'))).get())
          .map((row) => row.id)
          .toList();

  Future<String> _taxonomyLabel(String key, String locale) async {
    final rows = await (_database.select(
      _database.localTaxonomyTranslations,
    )..where((row) => row.taxonomyKey.equals(key))).get();
    for (final row in rows) {
      if (row.locale == locale) return row.label;
    }
    for (final row in rows) {
      if (row.locale == 'en') return row.label;
    }
    return key;
  }
}
