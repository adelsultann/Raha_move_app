import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_engine.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_explanation.dart';

void main() {
  test('maps reason codes plus the required position in canonical order', () {
    final reasons = buildExplanationReasons(
      reasonCodes: [
        RecommendationReasonCode.previousDiscomfort,
        RecommendationReasonCode.timeFit,
        RecommendationReasonCode.bodyAreaMatch,
      ],
      positionKey: 'seated',
    );

    expect(reasons, [
      ExplanationReason.bodyAreaMatch,
      ExplanationReason.timeFit,
      ExplanationReason.position,
      ExplanationReason.previousDiscomfort,
    ]);
  });

  test('omits the position line when the check-in allowed any position', () {
    final reasons = buildExplanationReasons(
      reasonCodes: const [RecommendationReasonCode.bodyAreaMatch],
      positionKey: null,
    );
    expect(reasons, const [ExplanationReason.bodyAreaMatch]);
  });

  test('ignores unknown reason codes', () {
    final reasons = buildExplanationReasons(
      reasonCodes: const ['unknown_code'],
      positionKey: null,
    );
    expect(reasons, isEmpty);
  });

  test('a preferred-position score alone does not add a position line', () {
    final reasons = buildExplanationReasons(
      reasonCodes: const [RecommendationReasonCode.positionPreference],
      positionKey: null,
    );
    expect(reasons, isEmpty);
  });

  test('produces a stable order regardless of reason-code order', () {
    final first = buildExplanationReasons(
      reasonCodes: [
        RecommendationReasonCode.difficultyMatch,
        RecommendationReasonCode.goalMatch,
      ],
      positionKey: null,
    );
    final second = buildExplanationReasons(
      reasonCodes: [
        RecommendationReasonCode.goalMatch,
        RecommendationReasonCode.difficultyMatch,
      ],
      positionKey: null,
    );
    expect(first, second);
    expect(first, const [
      ExplanationReason.goalMatch,
      ExplanationReason.difficultyMatch,
    ]);
  });
}
