import 'package:freezed_annotation/freezed_annotation.dart';

import '../../check_in/domain/check_in_answers.dart';
import '../domain/recommendation_engine.dart';

part 'recommendation_state.freezed.dart';

/// The result of one recommendation flow for a completed check-in.
///
/// It carries the check-in answers (needed for the explanation), the ranked
/// result, and the id of the persisted top recommendation record. A null
/// [recommendationId] means no candidate survived filtering and nothing was
/// persisted.
@freezed
abstract class RecommendationState with _$RecommendationState {
  const factory RecommendationState({
    required CheckInAnswers checkIn,
    required RecommendationResult result,
    String? recommendationId,
  }) = _RecommendationState;

  const RecommendationState._();

  /// The selected top routine, or null when no candidate survived filtering.
  ScoredRoutine? get selected =>
      result.isEmpty ? null : result.recommendations.first;
}
