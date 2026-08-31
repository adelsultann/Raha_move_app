import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_session.freezed.dart';

/// Coarse lifecycle of an in-memory playback session (RAHA-051). Durable
/// persistence, restore, and completion-policy evaluation belong to RAHA-052.
enum PlaybackStatus { playing, paused, completed }

/// Terminal/per-step state mirroring the RAHA-001 step-state rules.
enum StepPlaybackState { pending, completed, partial, skipped }

/// The pure step-state rule from RAHA-001.
///
/// - a step that reaches its full duration is `completed` with credited time =
///   target (and no skip request);
/// - a step that started playback and was then left early is `partial`,
///   preserving its credited active time (regardless of a skip request);
/// - a step skipped before any active playback is `skipped` (0 credited).
StepPlaybackState terminalStateFor({
  required int creditedSeconds,
  required int durationSeconds,
  required bool skipRequested,
}) {
  if (creditedSeconds >= durationSeconds && !skipRequested) {
    return StepPlaybackState.completed;
  }
  if (creditedSeconds > 0 && creditedSeconds < durationSeconds) {
    return StepPlaybackState.partial;
  }
  return StepPlaybackState.skipped;
}

/// The mutable playback view of one routine step.
@freezed
abstract class RoutineStepPlayback with _$RoutineStepPlayback {
  const factory RoutineStepPlayback({
    required String stepId,
    required String exerciseId,
    required String name,
    String? shortCue,
    required int durationSeconds,
    required StepPlaybackState state,
    required int creditedSeconds,
    required bool skipRequested,
  }) = _RoutineStepPlayback;
}

/// The in-memory session model the player controller mutates on each action.
///
/// [creditedSeconds] never exceeds a step's target duration and pause/resume
/// never double-counts active time.
@freezed
abstract class RoutinePlaybackSession with _$RoutinePlaybackSession {
  const factory RoutinePlaybackSession({
    required String sessionId,
    required String routineId,
    required int routineVersion,
    required String routineName,
    String? recommendationId,
    required PlaybackStatus status,
    required int currentStepIndex,
    required List<RoutineStepPlayback> steps,
  }) = _RoutinePlaybackSession;

  const RoutinePlaybackSession._();

  int get totalCreditedSeconds =>
      steps.fold(0, (total, step) => total + step.creditedSeconds);

  RoutineStepPlayback get currentStep => steps[currentStepIndex];

  bool get isLastStep => currentStepIndex == steps.length - 1;

  bool get isCompleted => status == PlaybackStatus.completed;
}
