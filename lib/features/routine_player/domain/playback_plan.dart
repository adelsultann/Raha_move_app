import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

part 'playback_plan.freezed.dart';

/// The localized, ordered playback plan for one routine (RAHA-051).
///
/// It is a read-only projection resolved from the local content cache: each
/// step carries its localized name and cue plus the single resolved
/// [MediaDelivery] that RAHA-050 already prepared. It is not the canonical
/// `Routine` model.
@freezed
abstract class RoutinePlaybackPlan with _$RoutinePlaybackPlan {
  const factory RoutinePlaybackPlan({
    required String routineId,
    required int routineVersion,
    required String routineName,
    required List<RoutineStepPlan> steps,
  }) = _RoutinePlaybackPlan;

  const RoutinePlaybackPlan._();

  /// One [MediaDelivery] per step, in step order.
  List<MediaDelivery> get media => [for (final step in steps) step.media];
}

/// One schedulable step resolved for playback.
@freezed
abstract class RoutineStepPlan with _$RoutineStepPlan {
  const factory RoutineStepPlan({
    required String stepId,
    required String exerciseId,
    required String name,
    String? shortCue,
    required int durationSeconds,
    required MediaDelivery media,
  }) = _RoutineStepPlan;
}
