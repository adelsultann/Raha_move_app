import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/routine_readiness.dart';
import 'readiness_providers.dart';

part 'routine_readiness_controller.g.dart';

/// The transient lifecycle of the pre-start readiness check. It is deliberately
/// a plain value (not a generated model): [idle] means not yet checked,
/// [checking] lets the UI show progress, and [done] carries the terminal
/// [RoutineReadiness].
enum RoutineReadinessPhase { idle, checking, done }

final class RoutineReadinessState {
  const RoutineReadinessState.idle()
    : phase = RoutineReadinessPhase.idle,
      readiness = null;

  const RoutineReadinessState.checking()
    : phase = RoutineReadinessPhase.checking,
      readiness = null;

  const RoutineReadinessState.done(this.readiness)
    : phase = RoutineReadinessPhase.done;

  final RoutineReadinessPhase phase;
  final RoutineReadiness? readiness;

  bool get isChecking => phase == RoutineReadinessPhase.checking;
}

/// Runs the RAHA-050 pre-start readiness check for one recommended routine.
///
/// It resolves the routine's ordered media, marks steps with no playable media
/// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
/// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
/// and downloads missing assets). The result tells the UI whether to start,
/// retry, free storage, or choose another routine.
@riverpod
class RoutineReadinessController extends _$RoutineReadinessController {
  late String _routineId;

  @override
  RoutineReadinessState build(String routineId) {
    _routineId = routineId;
    return const RoutineReadinessState.idle();
  }

  /// Runs the check and returns the terminal readiness. Also updates [state] so
  /// the UI can reflect the checking phase.
  Future<RoutineReadiness> start() async {
    state = const RoutineReadinessState.checking();
    final readiness = await _check();
    state = RoutineReadinessState.done(readiness);
    return readiness;
  }

  Future<RoutineReadiness> _check() async {
    final resolution = await ref
        .read(routineMediaResolverProvider)
        .resolve(_routineId);

    if (resolution.missingExerciseIds.isNotEmpty || resolution.media.isEmpty) {
      return RoutineReadiness.missingMedia(
        missingExerciseCount: resolution.missingExerciseIds.isEmpty
            ? 1
            : resolution.missingExerciseIds.length,
      );
    }

    final preparer = await ref.read(routineMediaPreparerProvider.future);
    if (preparer == null) {
      // No media access scope (e.g. a guest with no Supabase identity yet).
      return const RoutineReadiness.unavailable(
        failureCode: MediaFailureCode.offline,
        canRetry: true,
      );
    }

    final preparation = await preparer.prepareForStart(
      resolution.media,
      explicitUserStart: true,
    );
    if (preparation.allReady) {
      final prepared = <MediaPrepared>[];
      for (final media in resolution.media) {
        final result = preparation.results[media.mediaId];
        if (result is! MediaPrepared) {
          // allReady guarantees MediaPrepared, but fail closed rather than
          // crash if a future preparer violates that invariant.
          return const RoutineReadiness.unavailable(
            failureCode: MediaFailureCode.downloadFailed,
            canRetry: true,
          );
        }
        prepared.add(result);
      }
      return RoutineReadiness.ready(preparedMedia: prepared);
    }

    return _interpretFailure(resolution, preparation);
  }

  RoutineReadiness _interpretFailure(
    RoutineMediaResolution resolution,
    RoutineMediaPreparation preparation,
  ) {
    for (final media in resolution.media) {
      if (preparation.results[media.mediaId] case MediaStorageNeeded(
        :final requiredBytes,
      )) {
        return RoutineReadiness.storageNeeded(requiredBytes: requiredBytes);
      }
    }
    for (final media in resolution.media) {
      if (preparation.results[media.mediaId] case MediaUnavailable(
        :final code,
        :final canRetry,
      )) {
        return RoutineReadiness.unavailable(
          failureCode: code,
          canRetry: canRetry,
        );
      }
    }
    return const RoutineReadiness.unavailable(
      failureCode: MediaFailureCode.downloadFailed,
      canRetry: true,
    );
  }
}
