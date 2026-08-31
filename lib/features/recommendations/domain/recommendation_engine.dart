import 'package:freezed_annotation/freezed_annotation.dart';

import '../../check_in/domain/check_in_answers.dart';
import '../../preferences/domain/user_preferences.dart';
import 'recommendation_candidate.dart';
import 'recommendation_config.dart';
import 'recommendation_history.dart';
import 'recommendation_rejection.dart';

part 'recommendation_engine.freezed.dart';

/// Stable, language-neutral reason keys stored with a recommendation and later
/// localized into the "why this routine" explanation (RAHA-042). A key appears
/// only when its factor actually influenced filtering or scoring.
abstract final class RecommendationReasonCode {
  static const String bodyAreaMatch = 'body_area_match';
  static const String goalMatch = 'goal_match';
  static const String timeFit = 'time_fit';
  static const String positionPreference = 'position_preference';
  static const String difficultyMatch = 'difficulty_match';
  static const String recentCompletion = 'recent_completion';
  static const String previousDiscomfort = 'previous_discomfort';
}

/// Stable keys for the numeric score breakdown recorded with a recommendation.
/// Penalty components are negative.
abstract final class RecommendationScoreComponent {
  static const String bodyAreaMatch = 'body_area_match';
  static const String goalMatch = 'goal_match';
  static const String timeFit = 'time_fit';
  static const String positionPreference = 'position_preference';
  static const String difficultyMatch = 'difficulty_match';
  static const String recencyPenalty = 'recency_penalty';
  static const String discomfortPenalty = 'discomfort_penalty';
}

/// All inputs a recommendation run needs. It is fully explicit so the engine is
/// a pure, deterministic function of its request: same inputs, candidate set,
/// configuration version, and history always produce the same result.
@freezed
abstract class RecommendationRequest with _$RecommendationRequest {
  const factory RecommendationRequest({
    required CheckInAnswers checkIn,
    required List<RecommendationCandidate> candidates,
    required UserPreferences preferences,
    required RecommendationHistory history,
    required RecommendationConfig config,

    /// The "now" instant for the recency window. Must be injected (not read
    /// from the system clock) so the engine is deterministic in tests.
    required DateTime now,

    /// The running application version (`MAJOR.MINOR.PATCH`).
    required String appVersion,

    /// Whether the user currently holds premium access. Free content is always
    /// eligible; premium candidates require this to be true.
    @Default(false) bool hasPremiumAccess,

    /// Accumulated refinements from rejected alternatives (RAHA-043). Empty by
    /// default; the engine applies exclusions and the difficulty override.
    @Default(RecommendationRefinement.initial)
    RecommendationRefinement refinement,
  }) = _RecommendationRequest;
}

/// One ranked, scored candidate in a recommendation result.
@freezed
abstract class ScoredRoutine with _$ScoredRoutine {
  const factory ScoredRoutine({
    required String routineId,

    /// Zero-based rank (0 = top candidate). Matches the local convention used
    /// by `local_recommendations.rank`.
    required int rank,

    /// Total score, comparable only within [RecommendationResult.engineVersion].
    required int score,

    /// Component key → integer contribution. Deterministically ordered.
    required Map<String, int> scoreComponents,

    /// Stable, language-neutral reason keys, in canonical order.
    required List<String> reasonCodes,
  }) = _ScoredRoutine;
}

/// The ranked outcome of one recommendation run. Empty when no candidate
/// survives filtering.
@freezed
abstract class RecommendationResult with _$RecommendationResult {
  const factory RecommendationResult({
    required String engineVersion,
    required List<ScoredRoutine> recommendations,
  }) = _RecommendationResult;

  const RecommendationResult._();

  bool get isEmpty => recommendations.isEmpty;
}

/// The deterministic, on-device recommendation engine.
///
/// Implementations must run entirely against the supplied request and must not
/// depend on Flutter widgets, Drift, Supabase, media providers, or the system
/// clock.
abstract interface class RoutineRecommendationEngine {
  RecommendationResult recommend(RecommendationRequest request);
}
