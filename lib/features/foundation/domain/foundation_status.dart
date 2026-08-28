import 'package:freezed_annotation/freezed_annotation.dart';

part 'foundation_status.freezed.dart';
part 'foundation_status.g.dart';

@freezed
abstract class FoundationStatus with _$FoundationStatus {
  const factory FoundationStatus({
    required bool isReady,
    required String environment,
  }) = _FoundationStatus;

  factory FoundationStatus.fromJson(Map<String, Object?> json) =>
      _$FoundationStatusFromJson(json);
}
