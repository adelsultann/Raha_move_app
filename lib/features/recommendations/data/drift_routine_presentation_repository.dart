import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';

import '../domain/routine_presentation.dart';

/// Loads the localized, read-only [RoutinePresentation] for one routine from the
/// local Drift content cache.
///
/// Names, summaries, and movement names resolve in the requested locale with an
/// `en` fallback (the catalog fallback order documented in `database.md`).
/// Position and equipment keys stay stable and language-neutral so the
/// presentation layer localizes them through the app resources.
final class DriftRoutinePresentationRepository {
  DriftRoutinePresentationRepository(this._database);

  final AppDatabase _database;

  Future<RoutinePresentation?> load(String routineId, String locale) async {
    final routine = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.id.equals(routineId))).getSingleOrNull();
    if (routine == null || routine.status != 'published') return null;

    final difficulty = DifficultyLevel.values.asNameMap()[routine.difficulty];
    if (difficulty == null) return null;

    final translations = await (_database.select(
      _database.localRoutineTranslations,
    )..where((r) => r.routineId.equals(routineId))).get();
    final nameByLocale = <String, String>{
      for (final t in translations) t.locale: t.name,
    };
    final summaryByLocale = <String, String>{
      for (final t in translations) t.locale: t.summary,
    };

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
    final exerciseTranslations = await (_database.select(
      _database.localExerciseTranslations,
    )..where((r) => r.exerciseId.isIn(exerciseIds))).get();
    final nameByExercise = <String, Map<String, String>>{};
    for (final t in exerciseTranslations) {
      nameByExercise.putIfAbsent(t.exerciseId, () => {})[t.locale] = t.name;
    }

    final assignments = await (_database.select(
      _database.localRoutineTaxonomies,
    )..where((r) => r.routineId.equals(routineId))).get();
    final taxonomyKeys = assignments.map((a) => a.taxonomyKey).toSet();
    final taxonomies = await (_database.select(
      _database.localTaxonomies,
    )..where((r) => r.key.isIn(taxonomyKeys))).get();
    final kindByKey = {
      for (final taxonomy in taxonomies) taxonomy.key: taxonomy.kind,
    };

    return RoutinePresentation(
      routineId: routineId,
      name: _pick(nameByLocale, locale),
      summary: _pick(summaryByLocale, locale),
      movements: [
        for (final step in steps)
          MovementPreviewEntry(
            name: _pick(nameByExercise[step.exerciseId] ?? const {}, locale),
            durationSeconds: step.durationSeconds,
          ),
      ],
      difficulty: difficulty,
      estimatedDurationSeconds: routine.estimatedDurationSeconds,
      positions: _keysOfKind(assignments, kindByKey, 'position'),
      equipment: _keysOfKind(assignments, kindByKey, 'equipment'),
    );
  }

  static String _pick(Map<String, String> byLocale, String locale) {
    final value = byLocale[locale] ?? byLocale['en'];
    if (value != null) return value;
    return byLocale.isEmpty ? '' : byLocale.values.first;
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
