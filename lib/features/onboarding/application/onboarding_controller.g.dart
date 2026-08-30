// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the active user has completed onboarding. When false, the app shows
/// language selection and the onboarding pages; when true, it goes straight to
/// the app. Completion is persisted locally and never re-shown unless the data
/// is cleared or a fresh identity is created.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Whether the active user has completed onboarding. When false, the app shows
/// language selection and the onboarding pages; when true, it goes straight to
/// the app. Completion is persisted locally and never re-shown unless the data
/// is cleared or a fresh identity is created.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, bool> {
  /// Whether the active user has completed onboarding. When false, the app shows
  /// language selection and the onboarding pages; when true, it goes straight to
  /// the app. Completion is persisted locally and never re-shown unless the data
  /// is cleared or a fresh identity is created.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'08c1f867d1ef3075569f320041441a7c94828a5e';

/// Whether the active user has completed onboarding. When false, the app shows
/// language selection and the onboarding pages; when true, it goes straight to
/// the app. Completion is persisted locally and never re-shown unless the data
/// is cleared or a fresh identity is created.

abstract class _$OnboardingController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
