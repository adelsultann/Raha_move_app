import 'package:raha_move/features/media/domain/media_delivery.dart';

/// The outcome of the pre-start readiness check for one recommended routine
/// (RAHA-050). It is a pure product value: the data layer resolves media, the
/// media preparation service repairs/verifies the cache, and this type carries
/// only what the presentation layer needs to decide whether it is safe to start.
enum RoutineReadinessStatus {
  /// Every scheduled step has prepared, playable media. Safe to start.
  ready,

  /// Required media exists but could not be prepared (offline, entitlement,
  /// download, or integrity failure). A retry may help.
  unavailable,

  /// Required media exists but the device lacks space to cache it.
  storageNeeded,

  /// One or more steps have no published playable media at all. The routine
  /// cannot be played and a new recommendation must be selected.
  missingMedia,
}

final class RoutineReadiness {
  const RoutineReadiness.ready({required this.preparedMedia})
    : status = RoutineReadinessStatus.ready,
      failureCode = null,
      canRetry = false,
      requiredBytes = null,
      missingExerciseCount = 0;

  const RoutineReadiness.unavailable({
    required this.failureCode,
    required this.canRetry,
  }) : status = RoutineReadinessStatus.unavailable,
       preparedMedia = const [],
       requiredBytes = null,
       missingExerciseCount = 0;

  const RoutineReadiness.storageNeeded({required this.requiredBytes})
    : status = RoutineReadinessStatus.storageNeeded,
      preparedMedia = const [],
      failureCode = null,
      canRetry = false,
      missingExerciseCount = 0;

  const RoutineReadiness.missingMedia({required this.missingExerciseCount})
    : status = RoutineReadinessStatus.missingMedia,
      preparedMedia = const [],
      failureCode = null,
      canRetry = false,
      requiredBytes = null;

  final RoutineReadinessStatus status;

  /// Ordered prepared media (step order) when [status] is [ready].
  final List<MediaPrepared> preparedMedia;

  /// The first terminal media failure when [status] is [unavailable].
  final MediaFailureCode? failureCode;

  /// Whether a retry of the same routine is meaningful.
  final bool canRetry;

  /// Approximate bytes still required when [status] is [storageNeeded].
  final int? requiredBytes;

  /// Number of steps with no playable media when [status] is [missingMedia].
  final int missingExerciseCount;

  bool get isReady => status == RoutineReadinessStatus.ready;
}

/// The ordered required media for one routine plus any step whose exercise has
/// no published playable media asset at all.
final class RoutineMediaResolution {
  const RoutineMediaResolution({
    required this.media,
    required this.missingExerciseIds,
  });

  /// One [MediaDelivery] per schedulable step, in step order. The resolver
  /// prefers the published playable preferred asset and falls back to another
  /// published playable asset for the same exercise when the preferred one is
  /// unusable.
  final List<MediaDelivery> media;

  /// Exercises referenced by a step but with no published playable media.
  final List<String> missingExerciseIds;
}

/// Resolves the required media deliveries for one routine from the local
/// content cache, independent of any network or media SDK.
abstract interface class RoutineMediaResolver {
  Future<RoutineMediaResolution> resolve(String routineId);
}

/// Prepares (verifies/repairs/downloads) one routine's media. Separated from
/// the resolver so the readiness controller can be tested with a lightweight
/// fake rather than the full media preparation stack.
abstract interface class RoutineMediaPreparer {
  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> media, {
    required bool explicitUserStart,
  });
}
