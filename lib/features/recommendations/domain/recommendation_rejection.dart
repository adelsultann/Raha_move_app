import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise_library/domain/content_models.dart';
import 'recommendation_candidate.dart';

part 'recommendation_rejection.freezed.dart';

/// The five rejection reasons a user can give for a recommendation.
///
/// Keys are stable, language-neutral, and match the `rejection_reason` values
/// the analytics allowlist documents (RAHA-015) and the RAHA-043 decision note.
enum RecommendationRejectionReason {
  tooEasy('too_easy'),
  tooDifficult('too_difficult'),
  position('position'),
  discomfort('discomfort'),
  other('other');

  const RecommendationRejectionReason(this.key);

  /// The stable key persisted on the recommendation record and used in
  /// analytics. Never a localized label.
  final String key;

  static RecommendationRejectionReason fromKey(String key) =>
      values.firstWhere((reason) => reason.key == key);
}

/// The accumulated refinements applied to a recommendation run after one or more
/// rejections. It is part of the engine request, so the alternative sequence is
/// deterministic and versioned rather than hidden in widget code.
@freezed
abstract class RecommendationRefinement with _$RecommendationRefinement {
  const factory RecommendationRefinement({
    /// Routines already rejected for this check-in. A rejected routine is never
    /// immediately returned while another compatible candidate exists, and this
    /// set grows monotonically, guaranteeing the sequence terminates.
    @Default(<String>{}) Set<String> rejectedRoutineIds,

    /// Position keys the user cannot use (constraint: filtering).
    @Default(<String>{}) Set<String> excludedPositionKeys,

    /// Body-area keys the user reports uncomfortable (constraint: filtering).
    @Default(<String>{}) Set<String> excludedBodyAreaKeys,

    /// Preferred difficulty after `too_easy`/`too_difficult` (preference:
    /// scoring). Null means "use the experience-level default".
    DifficultyLevel? difficultyOverride,
  }) = _RecommendationRefinement;

  const RecommendationRefinement._();

  static const RecommendationRefinement initial = RecommendationRefinement();
}

/// Applies one rejection to [current], producing the refinement for the next
/// run. This is a pure, deterministic function of its inputs.
///
/// Every rejection adds [rejected] to [RecommendationRefinement.rejectedRoutineIds],
/// so a finite candidate set is guaranteed to reach the empty state rather than
/// loop. Constraint reasons (`position`, `discomfort`) add filtering exclusions;
/// preference reasons (`tooEasy`, `tooDifficult`) shift the difficulty override.
RecommendationRefinement refineAfterRejection({
  required RecommendationRefinement current,
  required RecommendationRejectionReason reason,
  required RecommendationCandidate rejected,
  required DifficultyLevel experienceDifficulty,
}) {
  final rejectedIds = {...current.rejectedRoutineIds, rejected.routineId};
  final excludedPositions = {...current.excludedPositionKeys};
  final excludedAreas = {...current.excludedBodyAreaKeys};
  var difficultyOverride = current.difficultyOverride;

  switch (reason) {
    case RecommendationRejectionReason.tooEasy:
      difficultyOverride = _shift(
        difficultyOverride ?? experienceDifficulty,
        1,
      );
    case RecommendationRejectionReason.tooDifficult:
      difficultyOverride = _shift(
        difficultyOverride ?? experienceDifficulty,
        -1,
      );
    case RecommendationRejectionReason.position:
      excludedPositions.addAll(rejected.positions);
    case RecommendationRejectionReason.discomfort:
      excludedAreas.addAll(rejected.bodyAreas);
    case RecommendationRejectionReason.other:
      break; // Only the rejected routine is excluded.
  }

  return RecommendationRefinement(
    rejectedRoutineIds: rejectedIds,
    excludedPositionKeys: excludedPositions,
    excludedBodyAreaKeys: excludedAreas,
    difficultyOverride: difficultyOverride,
  );
}

DifficultyLevel _shift(DifficultyLevel current, int delta) {
  final values = DifficultyLevel.values;
  final next = (current.index + delta).clamp(0, values.length - 1);
  return values[next];
}
