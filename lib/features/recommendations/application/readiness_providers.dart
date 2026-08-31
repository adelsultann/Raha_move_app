import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
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

/// The readiness preparer, backed by the media playback coordinator. Null while
/// there is no media access scope (a guest with no Supabase identity yet), which
/// the readiness controller surfaces as an unavailable/offline result.
@riverpod
Future<RoutineMediaPreparer?> routineMediaPreparer(Ref ref) async {
  final coordinator = await ref.watch(
    routineMediaPlaybackCoordinatorProvider.future,
  );
  return coordinator == null ? null : _CoordinatorPreparer(coordinator);
}

final class _CoordinatorPreparer implements RoutineMediaPreparer {
  const _CoordinatorPreparer(this._coordinator);

  final RoutineMediaPlaybackCoordinator _coordinator;

  @override
  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> media, {
    required bool explicitUserStart,
  }) =>
      _coordinator.prepareForStart(media, explicitUserStart: explicitUserStart);
}
