import 'package:freezed_annotation/freezed_annotation.dart';

import 'body_state.dart';

part 'check_in_answers.freezed.dart';

/// One complete, persisted daily check-in.
///
/// [goalKey], [bodyAreaKeys], and [positionKey] hold stable taxonomy keys (never
/// localized labels or provider data). [positionKey] is null for "any position".
@freezed
abstract class CheckInAnswers with _$CheckInAnswers {
  const factory CheckInAnswers({
    required BodyState bodyState,
    required String goalKey,
    required Set<String> bodyAreaKeys,
    required int availableMinutes,
    String? positionKey,
  }) = _CheckInAnswers;

  const CheckInAnswers._();
}
