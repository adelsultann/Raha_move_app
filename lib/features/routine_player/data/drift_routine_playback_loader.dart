import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/recommendations/data/drift_routine_media_resolver.dart';

import '../domain/playback_plan.dart';
import '../domain/routine_playback_loader.dart';

/// Drift-backed [RoutinePlaybackLoader].
///
/// Resolves one routine's ordered, localized playback plan from the local
/// content cache. It reuses [DriftRoutineMediaResolver] for the media-selection
/// rule (prefer the published preferred playable asset, otherwise the first
/// published playable asset) and fails closed when the resolved media does not
/// cover every schedulable published step.
final class DriftRoutinePlaybackLoader implements RoutinePlaybackLoader {
  DriftRoutinePlaybackLoader(this._database)
    : _mediaResolver = DriftRoutineMediaResolver(_database);

  final AppDatabase _database;
  final DriftRoutineMediaResolver _mediaResolver;

  @override
  Future<RoutinePlaybackPlan> load(String routineId, String locale) async {
    final routine = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.id.equals(routineId))).getSingleOrNull();
    // Routine-level access is independent of media. A cached file cannot grant
    // access to a retired or unauthorized routine.
    if (routine == null ||
        routine.status != 'published' ||
        routine.accessTier != 'free') {
      throw const RoutinePlaybackUnavailableException();
    }

    final routineName = _pick(await _routineNameByLocale(routineId), locale);

    final steps =
        await (_database.select(_database.localRoutineSteps)
              ..where(
                (r) =>
                    r.routineId.equals(routineId) &
                    r.status.equals('published'),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.position)]))
            .get();

    final exerciseIds = steps.map((s) => s.exerciseId).toSet();
    if (steps.isEmpty) throw const RoutinePlaybackUnavailableException();
    final exercises = await (_database.select(
      _database.localExercises,
    )..where((exercise) => exercise.id.isIn(exerciseIds))).get();
    if (exercises.length != exerciseIds.length ||
        exercises.any(
          (exercise) =>
              exercise.status != 'published' || !exercise.safetyApproved,
        )) {
      throw const RoutinePlaybackUnavailableException();
    }
    final exerciseTranslations = exerciseIds.isEmpty
        ? const <LocalExerciseTranslation>[]
        : await (_database.select(
            _database.localExerciseTranslations,
          )..where((r) => r.exerciseId.isIn(exerciseIds))).get();
    final nameByExercise = <String, Map<String, String>>{};
    final cueByExercise = <String, Map<String, String>>{};
    for (final t in exerciseTranslations) {
      nameByExercise.putIfAbsent(t.exerciseId, () => {})[t.locale] = t.name;
      final cue = t.shortCue;
      if (cue != null) {
        cueByExercise.putIfAbsent(t.exerciseId, () => {})[t.locale] = cue;
      }
    }

    final resolution = await _mediaResolver.resolve(routineId);
    if (resolution.media.length < steps.length) {
      // Readiness guarantees one media delivery per step, but fail closed
      // rather than produce a broken, out-of-alignment plan.
      throw const RoutinePlaybackUnavailableException();
    }

    return RoutinePlaybackPlan(
      routineId: routineId,
      routineVersion: routine.version,
      routineName: routineName,
      steps: [
        for (var i = 0; i < steps.length; i++)
          RoutineStepPlan(
            stepId: steps[i].id,
            exerciseId: steps[i].exerciseId,
            name: _pick(
              nameByExercise[steps[i].exerciseId] ?? const {},
              locale,
            ),
            shortCue: _pickNullable(
              cueByExercise[steps[i].exerciseId] ?? const {},
              locale,
            ),
            durationSeconds: steps[i].durationSeconds,
            media: resolution.media[i],
          ),
      ],
    );
  }

  Future<Map<String, String>> _routineNameByLocale(String routineId) async {
    final translations = await (_database.select(
      _database.localRoutineTranslations,
    )..where((r) => r.routineId.equals(routineId))).get();
    return {for (final t in translations) t.locale: t.name};
  }

  static String _pick(Map<String, String> byLocale, String locale) {
    final value = byLocale[locale] ?? byLocale['en'];
    if (value != null) return value;
    return byLocale.isEmpty ? '' : byLocale.values.first;
  }

  static String? _pickNullable(Map<String, String> byLocale, String locale) {
    final value = byLocale[locale] ?? byLocale['en'];
    if (value != null) return value;
    return byLocale.isEmpty ? null : byLocale.values.first;
  }
}
