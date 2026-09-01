import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/routine_feedback.dart';

part 'routine_feedback_state.freezed.dart';

/// Screen state for the optional post-routine feedback flow (RAHA-053).
///
/// [RoutineFeedbackError] retains the selected [rating] so a retry preserves
/// the user's choice and never asks them to choose again.
@freezed
sealed class RoutineFeedbackState with _$RoutineFeedbackState {
  const factory RoutineFeedbackState.loading() = RoutineFeedbackLoading;

  const factory RoutineFeedbackState.idle() = RoutineFeedbackIdle;

  const factory RoutineFeedbackState.saving({required FeedbackRating rating}) =
      RoutineFeedbackSaving;

  const factory RoutineFeedbackState.saved({required FeedbackRating rating}) =
      RoutineFeedbackSaved;

  const factory RoutineFeedbackState.error({required FeedbackRating rating}) =
      RoutineFeedbackError;
}
