import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_history.freezed.dart';

/// A minimal, read-only view of a previously completed routine attempt used by
/// the recommendation engine's recency penalty.
@freezed
abstract class RecentRoutineAttempt with _$RecentRoutineAttempt {
  const factory RecentRoutineAttempt({
    required String routineId,
    required DateTime completedAt,
  }) = _RecentRoutineAttempt;
}

/// Recommendation inputs drawn from the user's own history.
///
/// This is a purpose-built summary, not the canonical session/feedback models
/// (owned by RAHA-052/RAHA-053). It carries only what the engine needs: which
/// routines were recently completed and which exercises the user previously
/// reported as less comfortable.
@freezed
abstract class RecommendationHistory with _$RecommendationHistory {
  const factory RecommendationHistory({
    @Default(<RecentRoutineAttempt>[])
    List<RecentRoutineAttempt> recentAttempts,
    @Default(<String>{}) Set<String> uncomfortableExerciseIds,
  }) = _RecommendationHistory;

  const RecommendationHistory._();

  static const RecommendationHistory empty = RecommendationHistory();
}
