// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppearanceController)
final appearanceControllerProvider = AppearanceControllerProvider._();

final class AppearanceControllerProvider
    extends $AsyncNotifierProvider<AppearanceController, AppAppearance> {
  AppearanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceControllerHash();

  @$internal
  @override
  AppearanceController create() => AppearanceController();
}

String _$appearanceControllerHash() =>
    r'1eec447c67126f764a6fdbb13106ed7bc601a7f3';

abstract class _$AppearanceController extends $AsyncNotifier<AppAppearance> {
  FutureOr<AppAppearance> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppAppearance>, AppAppearance>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppAppearance>, AppAppearance>,
              AsyncValue<AppAppearance>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
