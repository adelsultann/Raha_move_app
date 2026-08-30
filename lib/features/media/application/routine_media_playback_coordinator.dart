import 'package:raha_move/features/media/application/media_preparation_service.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

/// The routine-player integration boundary. RAHA-051 can call this directly
/// without handling signed URLs, cache paths, or entitlement policy.
final class RoutineMediaPlaybackCoordinator {
  const RoutineMediaPlaybackCoordinator(this._preparation);

  final MediaPreparationService _preparation;

  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> routineMedia, {
    required bool explicitUserStart,
  }) => _preparation.prepareActiveRoutine(
    routineMedia,
    explicitUserStart: explicitUserStart,
    nextToPreloadMediaIds: routineMedia.skip(1).take(1).map((m) => m.mediaId),
  );

  Future<MediaPreparationResult?> preloadAfterStep(
    List<MediaDelivery> routineMedia, {
    required int currentStepIndex,
  }) {
    final nextIndex = currentStepIndex + 1;
    if (nextIndex >= routineMedia.length) return Future.value();
    return _preparation.preloadNext(
      routineMedia[nextIndex],
      activeRoutineMediaIds: routineMedia.map((media) => media.mediaId),
    );
  }
}
