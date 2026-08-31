import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';

import '../domain/recommendation_candidate.dart';

/// Loads read-optimized [RecommendationCandidate] snapshots from the local
/// Drift content cache.
///
/// It resolves the joins the engine should not care about — published routines
/// and their published steps, referenced exercises (safety + playable preferred
/// media), and the routine's body-area/goal/position taxonomy assignments — and
/// attaches the current content release's minimum app version. The engine then
/// applies its own deterministic filters on top of this projection.
final class DriftRecommendationCatalog {
  DriftRecommendationCatalog(this._database);

  final AppDatabase _database;

  Future<List<RecommendationCandidate>> loadPublishedCandidates() async {
    final release = await (_database.select(
      _database.localContentReleases,
    )..where((r) => r.isCurrent.equals(true))).getSingleOrNull();

    final routines = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.status.equals('published'))).get();
    if (routines.isEmpty) return const [];

    final routineIds = routines.map((r) => r.id).toSet();

    final steps =
        await (_database.select(_database.localRoutineSteps)..where(
              (r) =>
                  r.status.equals('published') & r.routineId.isIn(routineIds),
            ))
            .get();

    final assignments = await (_database.select(
      _database.localRoutineTaxonomies,
    )..where((r) => r.routineId.isIn(routineIds))).get();

    final taxonomyKeys = assignments.map((a) => a.taxonomyKey).toSet();
    final taxonomies = await (_database.select(
      _database.localTaxonomies,
    )..where((r) => r.key.isIn(taxonomyKeys))).get();
    final kindByKey = {
      for (final taxonomy in taxonomies) taxonomy.key: taxonomy.kind,
    };

    final exerciseIds = steps.map((s) => s.exerciseId).toSet();
    final exercises = await (_database.select(
      _database.localExercises,
    )..where((r) => r.id.isIn(exerciseIds))).get();
    final exerciseById = {
      for (final exercise in exercises) exercise.id: exercise,
    };

    final playable =
        await (_database.select(_database.localMediaAssets)..where(
              (r) =>
                  r.status.equals('published') &
                  r.isPreferred.equals(true) &
                  r.exerciseId.isIn(exerciseIds) &
                  (r.mediaType.equals('video') |
                      r.mediaType.equals('animation')),
            ))
            .get();
    final playableExerciseIds = playable.map((m) => m.exerciseId).toSet();

    final stepsByRoutine = <String, List<LocalRoutineStep>>{};
    for (final step in steps) {
      stepsByRoutine.putIfAbsent(step.routineId, () => []).add(step);
    }
    final assignmentsByRoutine = <String, List<LocalRoutineTaxonomy>>{};
    for (final assignment in assignments) {
      assignmentsByRoutine
          .putIfAbsent(assignment.routineId, () => [])
          .add(assignment);
    }

    final candidates = <RecommendationCandidate>[];
    for (final routine in routines) {
      final status = ContentStatus.values.asNameMap()[routine.status];
      final accessTier = AccessTier.values.asNameMap()[routine.accessTier];
      final difficulty = DifficultyLevel.values.asNameMap()[routine.difficulty];
      if (status == null || accessTier == null || difficulty == null) {
        continue; // invalid enum value: treat as unavailable, never guess.
      }

      final routineSteps =
          stepsByRoutine[routine.id] ?? const <LocalRoutineStep>[];
      final routineExerciseIds = routineSteps.map((s) => s.exerciseId).toSet();
      final routineAssignments =
          assignmentsByRoutine[routine.id] ?? const <LocalRoutineTaxonomy>[];

      candidates.add(
        RecommendationCandidate(
          routineId: routine.id,
          status: status,
          accessTier: accessTier,
          difficulty: difficulty,
          estimatedDurationSeconds: routine.estimatedDurationSeconds,
          bodyAreas: _keysOfKind(routineAssignments, kindByKey, 'body_area'),
          goals: _keysOfKind(routineAssignments, kindByKey, 'goal'),
          positions: _keysOfKind(routineAssignments, kindByKey, 'position'),
          exerciseIds: routineExerciseIds,
          exercisesSafetyApproved: routineExerciseIds.every(
            (id) => exerciseById[id]?.safetyApproved ?? false,
          ),
          exercisesHavePlayableMedia: routineExerciseIds.every(
            playableExerciseIds.contains,
          ),
          minimumAppVersion: release?.minimumAppVersion,
        ),
      );
    }
    return candidates;
  }

  static Set<String> _keysOfKind(
    List<LocalRoutineTaxonomy> assignments,
    Map<String, String> kindByKey,
    String kind,
  ) => assignments
      .where((assignment) => kindByKey[assignment.taxonomyKey] == kind)
      .map((assignment) => assignment.taxonomyKey)
      .toSet();
}
