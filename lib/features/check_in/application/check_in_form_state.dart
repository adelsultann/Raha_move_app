import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/body_area.dart';
import '../domain/body_state.dart';
import '../domain/check_in_answers.dart';
import '../domain/check_in_goal.dart';
import '../domain/check_in_position.dart';

part 'check_in_form_state.freezed.dart';

/// The in-progress five-step check-in capture.
///
/// Required fields ([bodyState], [goal], [availableMinutes], [position]) start
/// unset so the flow can require an explicit choice before continuing;
/// [bodyAreas] requires at least one selection. The state is retained by the
/// keepAlive controller so going backward or returning after an interruption
/// preserves answers.
@freezed
abstract class CheckInFormState with _$CheckInFormState {
  const factory CheckInFormState({
    BodyState? bodyState,
    CheckInGoal? goal,
    @Default(<BodyArea>{}) Set<BodyArea> bodyAreas,
    int? availableMinutes,
    CheckInPosition? position,
  }) = _CheckInFormState;

  const CheckInFormState._();

  /// Whether every step has a valid answer and the check-in can be persisted.
  bool get isValid =>
      bodyState != null &&
      goal != null &&
      bodyAreas.isNotEmpty &&
      availableMinutes != null &&
      position != null;

  /// The persisted value. Call only when [isValid] is true.
  CheckInAnswers toAnswers() => CheckInAnswers(
    bodyState: bodyState!,
    goalKey: goal!.key,
    bodyAreaKeys: bodyAreas.map((area) => area.key).toSet(),
    availableMinutes: availableMinutes!,
    positionKey: position!.key,
  );
}
