import 'recommendation_engine.dart';

/// The user-facing explanation factors, in canonical display order.
///
/// The recommendation's stored reason keys (see [RecommendationReasonCode])
/// already encode the scoring factors; this enum adds the check-in's required
/// [position] as a filtering factor so the explanation can mention it. Each
/// factor maps to one localized sentence that references the user's actual
/// check-in answers.
enum ExplanationReason {
  bodyAreaMatch,
  goalMatch,
  timeFit,
  position,
  difficultyMatch,
  recentCompletion,
  previousDiscomfort,
}

/// Maps a recommendation's reason keys (plus the check-in's required position)
/// into the ordered list of explanation factors to display.
///
/// This is a pure, deterministic function: same inputs always produce the same
/// order. A factor appears only when it actually influenced filtering or
/// scoring, so the explanation never mentions factors that were not involved.
List<ExplanationReason> buildExplanationReasons({
  required List<String> reasonCodes,
  required String? positionKey,
}) {
  final reasons = <ExplanationReason>[];
  if (reasonCodes.contains(RecommendationReasonCode.bodyAreaMatch)) {
    reasons.add(ExplanationReason.bodyAreaMatch);
  }
  if (reasonCodes.contains(RecommendationReasonCode.goalMatch)) {
    reasons.add(ExplanationReason.goalMatch);
  }
  if (reasonCodes.contains(RecommendationReasonCode.timeFit)) {
    reasons.add(ExplanationReason.timeFit);
  }
  // The explanation mentions the check-in's required position (a hard filter);
  // the softer preferred-position scoring is not surfaced as its own line.
  if (positionKey != null) {
    reasons.add(ExplanationReason.position);
  }
  if (reasonCodes.contains(RecommendationReasonCode.difficultyMatch)) {
    reasons.add(ExplanationReason.difficultyMatch);
  }
  if (reasonCodes.contains(RecommendationReasonCode.recentCompletion)) {
    reasons.add(ExplanationReason.recentCompletion);
  }
  if (reasonCodes.contains(RecommendationReasonCode.previousDiscomfort)) {
    reasons.add(ExplanationReason.previousDiscomfort);
  }
  return reasons;
}
