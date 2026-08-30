import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/experience_level.dart';
import '../domain/movement_position.dart';
import '../domain/user_preferences.dart';

part 'preferences_form_state.freezed.dart';

/// The in-progress capture form for basic preferences.
///
/// [experienceLevel] is nullable so the capture flow can require an explicit
/// choice before continuing; every other field has a gentle default. This state
/// is retained in memory (keepAlive) so going backward or returning after an
/// interruption preserves the user's answers.
@freezed
abstract class PreferencesFormState with _$PreferencesFormState {
  const factory PreferencesFormState({
    ExperienceLevel? experienceLevel,
    @Default(<MovementPosition>{}) Set<MovementPosition> preferredPositions,
    @Default(3) int weeklyGoalDays,
    @Default(false) bool reminderInterest,
  }) = _PreferencesFormState;

  const PreferencesFormState._();

  /// Whether the required fields are complete enough to persist.
  bool get isValid => experienceLevel != null;

  /// The persisted value. Call only when [isValid] is true.
  UserPreferences toPreferences() => UserPreferences(
    experienceLevel: experienceLevel!,
    preferredPositions: preferredPositions,
    weeklyGoalDays: weeklyGoalDays,
    reminderInterest: reminderInterest,
  );
}
