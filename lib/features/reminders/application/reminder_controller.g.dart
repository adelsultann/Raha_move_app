// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReminderController)
final reminderControllerProvider = ReminderControllerProvider._();

final class ReminderControllerProvider
    extends $AsyncNotifierProvider<ReminderController, ReminderSettingsState> {
  ReminderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderControllerHash();

  @$internal
  @override
  ReminderController create() => ReminderController();
}

String _$reminderControllerHash() =>
    r'c46c52da0340b1cbbb6891ac1f0b1b1f49155fb2';

abstract class _$ReminderController
    extends $AsyncNotifier<ReminderSettingsState> {
  FutureOr<ReminderSettingsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ReminderSettingsState>, ReminderSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ReminderSettingsState>,
                ReminderSettingsState
              >,
              AsyncValue<ReminderSettingsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
