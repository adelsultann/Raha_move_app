import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise_library/domain/content_models.dart';

part 'recommendation_candidate.freezed.dart';

/// A read-optimized snapshot of one routine for the recommendation engine.
///
/// This is deliberately a purpose-built projection rather than the canonical
/// `Routine`/`Exercise` catalog models: the engine only needs the fields that
/// drive filtering and scoring, and the data layer resolves the cross-table
/// joins (steps → exercises → media) into the booleans below. The canonical
/// `Routine` model remains the catalog source of truth and is not reconstructed
/// here.
@freezed
abstract class RecommendationCandidate with _$RecommendationCandidate {
  const factory RecommendationCandidate({
    required String routineId,
    required ContentStatus status,
    required AccessTier accessTier,
    required DifficultyLevel difficulty,
    required int estimatedDurationSeconds,

    /// Stable taxonomy keys the routine addresses (body_area kind).
    required Set<String> bodyAreas,

    /// Stable taxonomy keys the routine serves (goal kind).
    required Set<String> goals,

    /// Stable taxonomy keys the routine can be performed in (position kind).
    required Set<String> positions,

    /// Stable exercise ids referenced by the routine's published steps.
    required Set<String> exerciseIds,

    /// True only when every referenced exercise is safety-approved.
    required bool exercisesSafetyApproved,

    /// True only when every referenced exercise has a preferred, published,
    /// playable media asset.
    required bool exercisesHavePlayableMedia,

    /// Minimum app version required by the current content release, if any.
    String? minimumAppVersion,
  }) = _RecommendationCandidate;
}
