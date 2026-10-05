import 'dart:convert';

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
    final guidanceByExercise =
        <String, Map<String, LocalExerciseTranslation>>{};
    for (final t in exerciseTranslations) {
      nameByExercise.putIfAbsent(t.exerciseId, () => {})[t.locale] = t.name;
      guidanceByExercise.putIfAbsent(t.exerciseId, () => {})[t.locale] = t;
    }

    final approvedExercises =
        await (_database.select(_database.localExercises)..where(
              (e) =>
                  e.id.isIn(exerciseIds) &
                  e.status.equals('published') &
                  e.safetyApproved.equals(true) &
                  e.accessTier.equals('free'),
            ))
            .get();
    final previewableIds = routine.accessTier == 'free'
        ? approvedExercises.map((e) => e.id).toSet()
        : <String>{};

    final media =
        await (_database.select(_database.localMediaAssets)..where(
              (m) =>
                  m.exerciseId.isIn(exerciseIds) & m.status.equals('published'),
            ))
            .get();
    final thumbnails = <String, String>{};
    final videos = <String, LocalMediaAsset>{};
    for (final asset in media) {
      final reference = asset.deliveryReference;
      if (!reference.startsWith('asset:')) continue;
      final path = reference.substring(6);
      if (path.startsWith('assets/starter_content/') &&
          path.endsWith('.mp4') &&
          asset.mediaType == 'video' &&
          asset.checksumSha256.isNotEmpty &&
          previewableIds.contains(asset.exerciseId)) {
        final previous = videos[asset.exerciseId];
        if (previous == null || (!previous.isPreferred && asset.isPreferred)) {
          videos[asset.exerciseId] = asset;
        }
      }
      if (path.endsWith('.mp4') || path.endsWith('.gif')) {
        final name = path.split('/').last.split('.').first;
        thumbnails.putIfAbsent(
          asset.exerciseId,
          () => 'assets/images/exercise_thumbnails/$name.jpg',
        );
      } else if (asset.mimeType.startsWith('image/')) {
        thumbnails[asset.exerciseId] = path;
      }
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
            stepId: step.id,
            thumbnailAsset: thumbnails[step.exerciseId],
            videoAsset: videos[step.exerciseId]?.deliveryReference.substring(6),
            description: previewableIds.contains(step.exerciseId)
                ? _guidance(
                    guidanceByExercise[step.exerciseId],
                    locale,
                  )?.description
                : null,
            instructions: previewableIds.contains(step.exerciseId)
                ? _instructions(
                    _guidance(
                      guidanceByExercise[step.exerciseId],
                      locale,
                    )?.instructionsJson,
                  )
                : const [],
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

  static LocalExerciseTranslation? _guidance(
    Map<String, LocalExerciseTranslation>? translations,
    String locale,
  ) => translations?[locale] ?? translations?['en'];

  static List<String> _instructions(String? json) {
    if (json == null) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } on FormatException {
      return const [];
    }
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
