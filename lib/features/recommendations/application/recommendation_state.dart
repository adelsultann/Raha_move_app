import 'package:freezed_annotation/freezed_annotation.dart';

import '../../check_in/domain/check_in_answers.dart';
import '../domain/recommendation_engine.dart';
import '../domain/recommendation_rejection.dart';

part 'recommendation_state.freezed.dart';

/// The result of one recommendation flow for a completed check-in.
///
/// It carries the check-in answers (needed for the explanation), the ranked
/// result, the id of the persisted top recommendation record, and the
/// accumulated refinement. A null [recommendationId] means no candidate
/// survived filtering and nothing was persisted; when [refinement] has rejected
/// routines, that is an "no alternative" state rather than a first-run empty
/// catalog.
@freezed
abstract class RecommendationState with _$RecommendationState {
  const factory RecommendationState({
    required CheckInAnswers checkIn,
    required RecommendationResult result,
    String? recommendationId,
    @Default(RecommendationRefinement.initial)
    RecommendationRefinement refinement,
  }) = _RecommendationState;

  const RecommendationState._();

  /// The selected top routine, or null when no candidate survived filtering.
  ScoredRoutine? get selected =>
      result.isEmpty ? null : result.recommendations.first;

  /// True when at least one rejection has occurred and no alternative remains.
  bool get hasNoAlternative =>
      result.isEmpty && refinement.rejectedRoutineIds.isNotEmpty;
}
