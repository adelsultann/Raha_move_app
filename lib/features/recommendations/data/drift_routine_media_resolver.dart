import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

import '../domain/routine_readiness.dart';

/// Drift-backed [RoutineMediaResolver].
///
/// Resolves one routine's ordered, playable media from the local content cache:
/// for each published step it selects the exercise's preferred published
/// playable asset and, when that asset is unusable (e.g. a reserved `pending`
/// asset with no checksum), falls back to another published playable asset for
/// the same exercise. A step whose exercise has no playable asset is reported
/// in [RoutineMediaResolution.missingExerciseIds] so the readiness controller
/// can request a new recommendation rather than start a broken player.
final class DriftRoutineMediaResolver implements RoutineMediaResolver {
  DriftRoutineMediaResolver(this._database);

  static const String premiumEntitlementKey = 'premium';

  final AppDatabase _database;

  @override
  Future<RoutineMediaResolution> resolve(String routineId) async {
    final routine = await (_database.select(
      _database.localRoutines,
    )..where((r) => r.id.equals(routineId))).getSingleOrNull();
    if (routine == null || routine.status != 'published') {
      return const RoutineMediaResolution(media: [], missingExerciseIds: []);
    }

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
    final exercises = exerciseIds.isEmpty
        ? const <LocalExercise>[]
        : await (_database.select(_database.localExercises)..where(
                (e) => e.id.isIn(exerciseIds) & e.status.equals('published'),
              ))
              .get();
    final accessTierByExercise = {
      for (final exercise in exercises) exercise.id: exercise.accessTier,
    };

    final mediaAssets = exerciseIds.isEmpty
        ? const <LocalMediaAsset>[]
        : await (_database.select(_database.localMediaAssets)..where(
                (m) =>
                    m.exerciseId.isIn(exerciseIds) &
                    m.status.equals('published'),
              ))
              .get();
    final mediaByExercise = <String, List<LocalMediaAsset>>{};
    for (final asset in mediaAssets) {
      mediaByExercise.putIfAbsent(asset.exerciseId, () => []).add(asset);
    }

    final currentReleaseVersion = await _currentReleaseVersion();

    final media = <MediaDelivery>[];
    final missingExerciseIds = <String>[];
    for (final step in steps) {
      final delivery = _selectPlayableDelivery(
        mediaByExercise[step.exerciseId] ?? const [],
        accessTier: accessTierByExercise[step.exerciseId],
        version: currentReleaseVersion,
      );
      if (delivery == null) {
        missingExerciseIds.add(step.exerciseId);
      } else {
        media.add(delivery);
      }
    }

    return RoutineMediaResolution(
      media: media,
      missingExerciseIds: missingExerciseIds,
    );
  }

  Future<String> _currentReleaseVersion() async {
    final release = await (_database.select(
      _database.localContentReleases,
    )..where((r) => r.isCurrent.equals(true))).getSingleOrNull();
    return release?.version ?? '';
  }

  /// Selects the playable asset to deliver for one exercise. The published
  /// preferred playable asset wins; otherwise the first published playable
  /// asset is the fallback. Returns null when the exercise has no playable
  /// media, so the caller can mark the step as missing.
  MediaDelivery? _selectPlayableDelivery(
    List<LocalMediaAsset> assets, {
    required String? accessTier,
    required String version,
  }) {
    final playable = assets.where(_isPlayable).toList();
    if (playable.isEmpty) return null;

    LocalMediaAsset selected;
    final preferred = playable.where((m) => m.isPreferred).toList();
    if (preferred.length == 1) {
      selected = preferred.single;
    } else {
      // Fallback media: the first playable asset when the preferred asset is
      // absent, ambiguous, or not playable.
      selected = playable.first;
    }

    return MediaDelivery(
      mediaId: selected.id,
      deliveryReference: selected.deliveryReference,
      version: version,
      checksumSha256: selected.checksumSha256,
      requiredEntitlement: accessTier == 'premium'
          ? premiumEntitlementKey
          : null,
    );
  }

  static bool _isPlayable(LocalMediaAsset asset) =>
      (asset.mediaType == 'video' || asset.mediaType == 'animation') &&
      asset.checksumSha256.isNotEmpty;
}
