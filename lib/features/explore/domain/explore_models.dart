import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise_library/domain/content_models.dart';
import '../../recommendations/domain/routine_presentation.dart';

part 'explore_models.freezed.dart';

/// All filters intersect. An empty set means that dimension is not filtered.
@freezed
abstract class ExploreFilters with _$ExploreFilters {
  const factory ExploreFilters({
    @Default(<int>{}) Set<int> durationsMinutes,
    @Default(<String>{}) Set<String> bodyAreas,
    @Default(<String>{}) Set<String> positions,
    @Default(<DifficultyLevel>{}) Set<DifficultyLevel> difficulties,
    @Default(<String>{}) Set<String> equipment,
  }) = _ExploreFilters;

  const ExploreFilters._();

  bool get isEmpty =>
      durationsMinutes.isEmpty &&
      bodyAreas.isEmpty &&
      positions.isEmpty &&
      difficulties.isEmpty &&
      equipment.isEmpty;
}

@freezed
abstract class ExploreRoutineCard with _$ExploreRoutineCard {
  const factory ExploreRoutineCard({
    required String routineId,
    required String name,
    required String summary,
    required int durationSeconds,
    required DifficultyLevel difficulty,
    required Set<String> positions,
    required Set<String> equipment,
    required int movementCount,
  }) = _ExploreRoutineCard;
}

@freezed
abstract class ExploreCategory with _$ExploreCategory {
  const factory ExploreCategory({required String key, required String label}) =
      _ExploreCategory;
}

/// Routine-level authorization is intentionally separate from media readiness.
/// A routine must pass this check before a new session may be created.
enum RoutineStartBlock { retired, incompatible, unavailable, unauthorized }

@freezed
abstract class RoutineStartEligibility with _$RoutineStartEligibility {
  const factory RoutineStartEligibility.allowed() = RoutineStartAllowed;
  const factory RoutineStartEligibility.blocked(RoutineStartBlock reason) =
      RoutineStartBlocked;
}

@freezed
abstract class ExploreRoutineDetails with _$ExploreRoutineDetails {
  const factory ExploreRoutineDetails({
    required RoutinePresentation presentation,
    required RoutineStartEligibility eligibility,
    @Default(<String, String>{}) Map<String, String> equipmentLabels,
  }) = _ExploreRoutineDetails;
}

abstract interface class ExploreRepository {
  Future<List<ExploreCategory>> categories(String locale);
  Future<List<ExploreRoutineCard>> browse({
    required String locale,
    String? context,
    required ExploreFilters filters,
  });
  Future<ExploreRoutineDetails?> details(String routineId, String locale);
}
