import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';

const areaAssets = {
  'neck': 'NECK',
  'shoulders': 'SHOULDERS',
  'upper_back': 'POSTURE',
  'lower_back': 'LowerBack',
  'hips': 'HIPS',
  'knees': 'KNEES',
  'full_body': 'FULLBODY',
};

String areaAsset(String area) =>
    'assets/categories_icons/${areaAssets[area] ?? 'FULLBODY'}_category_icon.png';

class HomeExercise {
  const HomeExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.seconds,
    required this.area,
    required this.routineId,
    this.image,
  });
  final String id, name, description, area, routineId;
  final int seconds;
  final String? image;
}

class HomeCatalog {
  const HomeCatalog(this.exercises, this.sequences);
  final List<HomeExercise> exercises;
  final Map<String, List<HomeExercise>> sequences;
}

final homeCatalogProvider = FutureProvider<HomeCatalog>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final locale = ref.watch(exploreLocaleProvider).languageCode;
  final routines = await (db.select(
    db.localRoutines,
  )..where((r) => r.status.equals('published'))).get();
  final steps =
      await (db.select(db.localRoutineSteps)
            ..where(
              (r) =>
                  r.status.equals('published') &
                  r.routineId.isIn(routines.map((r) => r.id)),
            )
            ..orderBy([(r) => OrderingTerm.asc(r.position)]))
          .get();
  final exercises =
      await (db.select(db.localExercises)..where(
            (e) =>
                e.status.equals('published') &
                e.safetyApproved.equals(true) &
                e.accessTier.equals('free'),
          ))
          .get();
  final translations = await db.select(db.localExerciseTranslations).get();
  final areas = await db.select(db.localExerciseTaxonomies).get();
  final media = await (db.select(
    db.localMediaAssets,
  )..where((m) => m.status.equals('published'))).get();
  final byId = <String, HomeExercise>{};
  final sequences = <String, List<HomeExercise>>{};
  for (final step in steps) {
    if (!exercises.any((e) => e.id == step.exerciseId)) continue;
    final names = translations.where((t) => t.exerciseId == step.exerciseId);
    final translation =
        names.where((t) => t.locale == locale).firstOrNull ??
        names.where((t) => t.locale == 'en').firstOrNull;
    if (translation == null) continue;
    final area =
        areas
            .where(
              (t) =>
                  t.exerciseId == step.exerciseId &&
                  areaAssets.containsKey(t.taxonomyKey),
            )
            .firstOrNull
            ?.taxonomyKey ??
        'full_body';
    final asset = media
        .where(
          (m) =>
              m.exerciseId == step.exerciseId &&
              m.deliveryReference.startsWith('asset:assets/starter_content/') &&
              (m.mimeType == 'image/gif' ||
                  m.mimeType == 'image/png' ||
                  m.mimeType == 'image/webp' ||
                  m.mimeType == 'image/jpeg'),
        )
        .firstOrNull;
    final exercise = HomeExercise(
      id: step.exerciseId,
      name: translation.name,
      description: translation.description ?? translation.shortCue ?? '',
      seconds: step.durationSeconds,
      area: area,
      routineId: step.routineId,
      image: asset?.deliveryReference.substring(6),
    );
    byId.putIfAbsent(exercise.id, () => exercise);
    sequences.putIfAbsent(step.routineId, () => []).add(exercise);
  }
  return HomeCatalog(byId.values.toList(), sequences);
});

final savedExerciseIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(activeUserIdProvider);
  if (user == null) return Stream.value(<String>{});
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.localSavedExercises)
        ..where((r) => r.userId.equals(user)))
      .watch()
      .map((rows) => rows.map((r) => r.exerciseId).toSet());
});

Future<void> setExerciseSaved(WidgetRef ref, String id, bool saved) async {
  final user = ref.read(activeUserIdProvider);
  if (user == null) throw StateError('Missing active user');
  final db = ref.read(appDatabaseProvider);
  if (saved) {
    await db
        .into(db.localSavedExercises)
        .insertOnConflictUpdate(
          LocalSavedExercisesCompanion.insert(
            userId: user,
            exerciseId: id,
            savedAt: DateTime.now().toUtc(),
          ),
        );
  } else {
    await (db.delete(
      db.localSavedExercises,
    )..where((r) => r.userId.equals(user) & r.exerciseId.equals(id))).go();
  }
}
