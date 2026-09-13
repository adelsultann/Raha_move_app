import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/media/application/bundled_routine_media_preparer.dart';
import 'package:raha_move/features/media/application/media_providers.dart';
import 'package:raha_move/features/media/application/routine_media_playback_coordinator.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_routine_media_resolver.dart';
import '../domain/routine_readiness.dart';

part 'readiness_providers.g.dart';

/// Resolves one routine's ordered, playable media from the Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.
@Riverpod(keepAlive: true)
RoutineMediaResolver routineMediaResolver(Ref ref) =>
    DriftRoutineMediaResolver(ref.watch(appDatabaseProvider));

/// The readiness preparer uses bundled, integrity-checked starter media without
/// an account or network. Other routines remain backed by the trusted media
/// playback coordinator and are unavailable to an offline guest until cached.
@riverpod
Future<RoutineMediaPreparer?> routineMediaPreparer(Ref ref) async {
  final coordinator = await ref.watch(
    routineMediaPlaybackCoordinatorProvider.future,
  );
  return _ReadinessPreparer(coordinator: coordinator);
}

final class _ReadinessPreparer implements RoutineMediaPreparer {
  _ReadinessPreparer({required this.coordinator});

  final RoutineMediaPlaybackCoordinator? coordinator;
  final BundledRoutineMediaPreparer _bundled = BundledRoutineMediaPreparer();

  @override
  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> media, {
    required bool explicitUserStart,
  }) {
    if (media.isNotEmpty && media.every(BundledRoutineMediaPreparer.supports)) {
      return _bundled.prepareForStart(
        media,
        explicitUserStart: explicitUserStart,
      );
    }
    final remote = coordinator;
    if (remote == null) {
      return Future.value(
        RoutineMediaPreparation({
          for (final item in media)
            item.mediaId: MediaUnavailable(
              mediaId: item.mediaId,
              code: MediaFailureCode.offline,
            ),
        }),
      );
    }
    return remote.prepareForStart(media, explicitUserStart: explicitUserStart);
  }
}
