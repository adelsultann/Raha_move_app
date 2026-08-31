import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_catalog.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/database/app_database.dart' show generateUuidV4;
import '../../../core/telemetry/telemetry_providers.dart';
import '../../authentication/application/auth_controller.dart';
import '../domain/body_area.dart';
import '../domain/body_state.dart';
import '../domain/check_in_goal.dart';
import '../domain/check_in_position.dart';
import 'check_in_form_state.dart';
import 'check_in_providers.dart';

part 'check_in_controller.g.dart';

/// Captures and persists the five-step daily check-in.
///
/// The draft state and a stable check-in id are retained for the lifetime of the
/// container (keepAlive) so going backward or retrying a save preserves answers
/// and never creates a duplicate check-in. Persistence is local-first.
@Riverpod(keepAlive: true)
class CheckInController extends _$CheckInController {
  /// The supported available-time choices, in minutes.
  static const Set<int> supportedMinutes = {3, 5, 10, 15};

  String _checkInId = '';
  DateTime _startedAt = DateTime.now();
  bool _completed = false;

  @override
  CheckInFormState build() {
    // A fresh check-in starts a new id and start instant. Retrying [complete]
    // reuses these, so the same logical check-in is upserted, never duplicated.
    _checkInId = generateUuidV4();
    _startedAt = DateTime.now();
    _completed = false;
    return const CheckInFormState();
  }

  void selectBodyState(BodyState value) {
    state = state.copyWith(bodyState: value);
  }

  void selectGoal(CheckInGoal value) {
    state = state.copyWith(goal: value);
  }

  void toggleBodyArea(BodyArea area) {
    final areas = {...state.bodyAreas};
    if (!areas.remove(area)) areas.add(area);
    state = state.copyWith(bodyAreas: areas);
  }

  void selectTime(int minutes) {
    if (!supportedMinutes.contains(minutes)) {
      throw ArgumentError.value(minutes, 'minutes', 'Unsupported duration');
    }
    state = state.copyWith(availableMinutes: minutes);
  }

  void selectPosition(CheckInPosition position) {
    state = state.copyWith(position: position);
  }

  /// Persists the current draft and records a privacy-safe, categorical
  /// completion event. Returns true only when the draft was valid and actually
  /// persisted; the caller must not advance on a `false` result. Calling again
  /// after a successful completion is a no-op, so a retry never duplicates the
  /// check-in or its analytics event.
  Future<bool> complete() async {
    if (_completed) return true;

    final form = state;
    if (!form.isValid) return false;

    final auth = await ref.read(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) return false;

    await ref
        .read(checkInRepositoryProvider)
        .save(
          userId: userId,
          checkInId: _checkInId,
          startedAt: _startedAt,
          answers: form.toAnswers(),
        );

    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: AnalyticsEventName.checkInCompleted,
            properties: {
              AnalyticsPropertyKey.bodyState: form.bodyState!.key,
              AnalyticsPropertyKey.goalKey: form.goal!.key,
              AnalyticsPropertyKey.availableMinutes: form.availableMinutes!,
              AnalyticsPropertyKey.positionKey: form.position!.key ?? 'any',
              AnalyticsPropertyKey.bodyAreaCount: form.bodyAreas.length,
            },
          ),
        );

    _completed = true;
    return true;
  }
}
