import 'package:freezed_annotation/freezed_annotation.dart';

import 'experience_level.dart';
import 'movement_position.dart';

part 'user_preferences.freezed.dart';

/// The persisted basic preferences that immediately affect the experience.
///
/// This model is intentionally minimal: no height, weight, age, diagnosis, or
/// unrelated profile data. [preferredPositions] is empty to mean "any position".
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required ExperienceLevel experienceLevel,
    @Default(<MovementPosition>{}) Set<MovementPosition> preferredPositions,
    required int weeklyGoalDays,
    @Default(false) bool reminderInterest,
  }) = _UserPreferences;

  const UserPreferences._();

  /// The gentle default applied before a user has explicitly chosen anything.
  factory UserPreferences.initial() => const UserPreferences(
    experienceLevel: ExperienceLevel.beginner,
    weeklyGoalDays: 3,
  );
}
