import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_catalog.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/telemetry/telemetry_providers.dart';
import '../../authentication/application/auth_controller.dart';
import '../domain/experience_level.dart';
import '../domain/movement_position.dart';
import 'preferences_form_state.dart';
import 'preferences_providers.dart';

part 'preferences_controller.g.dart';

/// Captures and persists the user's basic preferences during setup.
///
/// The draft state is retained for the lifetime of the container so going
/// backward or returning after an interruption preserves answers. Persistence is
/// local-first; synchronization is owned by later preference-sync work.
@Riverpod(keepAlive: true)
class PreferencesController extends _$PreferencesController {
  @override
  PreferencesFormState build() => const PreferencesFormState();

  void selectExperience(ExperienceLevel level) {
    state = state.copyWith(experienceLevel: level);
  }

  void togglePosition(MovementPosition position) {
    final positions = {...state.preferredPositions};
    if (!positions.remove(position)) positions.add(position);
    state = state.copyWith(preferredPositions: positions);
  }

  void setWeeklyGoal(int days) {
    state = state.copyWith(weeklyGoalDays: days.clamp(1, 7).toInt());
  }

  void setReminderInterest(bool value) {
    state = state.copyWith(reminderInterest: value);
  }

  /// Persists the current draft and records a privacy-safe, categorical setup
  /// event. Returns true only when the draft was valid and actually persisted;
  /// the caller must not treat onboarding as complete on a `false` result.
  Future<bool> save() async {
    final form = state;
    if (!form.isValid) return false;

    final auth = await ref.read(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) return false;

    await ref
        .read(preferencesRepositoryProvider)
        .save(userId, form.toPreferences());

    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: AnalyticsEventName.preferencesSaved,
            properties: {
              AnalyticsPropertyKey.experienceLevel: form.experienceLevel!.code,
              AnalyticsPropertyKey.weeklyGoalDays: form.weeklyGoalDays,
              AnalyticsPropertyKey.reminderInterest: form.reminderInterest,
            },
          ),
        );

    return true;
  }
}
