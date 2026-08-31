import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_candidate.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_rejection.dart';

void main() {
  RecommendationCandidate candidate({
    String id = 'raha_rt_000001',
    DifficultyLevel difficulty = DifficultyLevel.beginner,
    Set<String> bodyAreas = const {'neck'},
    Set<String> positions = const {'seated'},
  }) => RecommendationCandidate(
    routineId: id,
    status: ContentStatus.published,
    accessTier: AccessTier.free,
    difficulty: difficulty,
    estimatedDurationSeconds: 300,
    bodyAreas: bodyAreas,
    goals: const {'ease_stiffness'},
    positions: positions,
    exerciseIds: const {'raha_ex_000001'},
    exercisesSafetyApproved: true,
    exercisesHavePlayableMedia: true,
  );

  test('rejection keys resolve and are stable', () {
    expect(RecommendationRejectionReason.tooEasy.key, 'too_easy');
    expect(RecommendationRejectionReason.tooDifficult.key, 'too_difficult');
    expect(RecommendationRejectionReason.position.key, 'position');
    expect(RecommendationRejectionReason.discomfort.key, 'discomfort');
    expect(RecommendationRejectionReason.other.key, 'other');
    expect(
      RecommendationRejectionReason.fromKey('too_easy'),
      RecommendationRejectionReason.tooEasy,
    );
  });

  test('every rejection adds the rejected routine id', () {
    final refined = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.other,
      rejected: candidate(),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    expect(refined.rejectedRoutineIds, {'raha_rt_000001'});
    expect(refined.excludedPositionKeys, isEmpty);
    expect(refined.excludedBodyAreaKeys, isEmpty);
    expect(refined.difficultyOverride, isNull);
  });

  test('position rejection excludes the rejected positions', () {
    final refined = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.position,
      rejected: candidate(positions: const {'seated', 'floor'}),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    expect(refined.excludedPositionKeys, {'seated', 'floor'});
    expect(refined.excludedBodyAreaKeys, isEmpty);
  });

  test('discomfort rejection excludes the rejected body areas', () {
    final refined = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.discomfort,
      rejected: candidate(bodyAreas: const {'neck', 'shoulders'}),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    expect(refined.excludedBodyAreaKeys, {'neck', 'shoulders'});
    expect(refined.excludedPositionKeys, isEmpty);
  });

  test('too easy raises and too difficult lowers the difficulty override', () {
    final easier = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.tooEasy,
      rejected: candidate(),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    expect(easier.difficultyOverride, DifficultyLevel.intermediate);

    final harder = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.tooDifficult,
      rejected: candidate(),
      experienceDifficulty: DifficultyLevel.intermediate,
    );
    expect(harder.difficultyOverride, DifficultyLevel.beginner);
  });

  test('difficulty shifts are clamped to the enum range', () {
    final advanced = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.tooEasy,
      rejected: candidate(),
      experienceDifficulty: DifficultyLevel.advanced,
    );
    expect(advanced.difficultyOverride, DifficultyLevel.advanced);

    final beginner = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.tooDifficult,
      rejected: candidate(),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    expect(beginner.difficultyOverride, DifficultyLevel.beginner);
  });

  test('refinements accumulate across rejections', () {
    final first = refineAfterRejection(
      current: RecommendationRefinement.initial,
      reason: RecommendationRejectionReason.position,
      rejected: candidate(id: 'raha_rt_000001', positions: const {'seated'}),
      experienceDifficulty: DifficultyLevel.beginner,
    );
    final second = refineAfterRejection(
      current: first,
      reason: RecommendationRejectionReason.discomfort,
      rejected: candidate(id: 'raha_rt_000002', bodyAreas: const {'neck'}),
      experienceDifficulty: DifficultyLevel.beginner,
    );

    expect(second.rejectedRoutineIds, {'raha_rt_000001', 'raha_rt_000002'});
    expect(second.excludedPositionKeys, {'seated'});
    expect(second.excludedBodyAreaKeys, {'neck'});
  });
}
