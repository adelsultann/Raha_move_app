import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_config.freezed.dart';

/// Versioned recommendation rules. See RAHA-001: recommendation rules, weights,
/// candidate filtering, and tie-breaking are versioned local configuration, not
/// hardcoded in widgets. Every persisted recommendation records [version] so
/// later rule tuning never rewrites historical decisions.
@freezed
abstract class RecommendationConfig with _$RecommendationConfig {
  const factory RecommendationConfig({
    /// Stable engine version recorded with every recommendation.
    required String version,

    /// Points added per selected body area the routine addresses.
    required int bodyAreaMatchWeight,

    /// Points added when the routine serves the selected goal.
    required int goalMatchWeight,

    /// Maximum time-fit points, scaled by how fully the routine fills the
    /// selected duration.
    required int timeMatchWeight,

    /// Points added when the routine can be performed in a preferred position.
    required int positionPreferenceWeight,

    /// Points added when the routine difficulty matches the experience level.
    required int difficultyMatchWeight,

    /// Points subtracted when the routine was recently completed.
    required int recencyPenaltyWeight,

    /// Points subtracted when the routine contains a previously uncomfortable
    /// exercise.
    required int discomfortPenaltyWeight,

    /// Allowed overshoot beyond the selected time in seconds. The MVP default
    /// is zero: a routine never exceeds the selected time unless a later
    /// product decision configures and explains a tolerance.
    required int maxDurationOvershootSeconds,

    /// How many days a prior completion remains "recent".
    required int recencyWindowDays,
  }) = _RecommendationConfig;

  const RecommendationConfig._();

  /// The approved MVP rules. Weights mirror the initial weighted approach in
  /// `project-structure.md` (body area 40, goal 25, time 20, position 15,
  /// recent -10) with added difficulty (+10) and discomfort (-20) factors.
  static const RecommendationConfig rulesV1 = RecommendationConfig(
    version: 'rules_v1',
    bodyAreaMatchWeight: 40,
    goalMatchWeight: 25,
    timeMatchWeight: 20,
    positionPreferenceWeight: 15,
    difficultyMatchWeight: 10,
    recencyPenaltyWeight: 10,
    discomfortPenaltyWeight: 20,
    maxDurationOvershootSeconds: 0,
    recencyWindowDays: 7,
  );
}
