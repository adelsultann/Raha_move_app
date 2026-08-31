// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Captures and persists the five-step daily check-in.
///
/// The draft state and a stable check-in id are retained for the lifetime of the
/// container (keepAlive) so going backward or retrying a save preserves answers
/// and never creates a duplicate check-in. Persistence is local-first.

@ProviderFor(CheckInController)
final checkInControllerProvider = CheckInControllerProvider._();

/// Captures and persists the five-step daily check-in.
///
/// The draft state and a stable check-in id are retained for the lifetime of the
/// container (keepAlive) so going backward or retrying a save preserves answers
/// and never creates a duplicate check-in. Persistence is local-first.
final class CheckInControllerProvider
    extends $NotifierProvider<CheckInController, CheckInFormState> {
  /// Captures and persists the five-step daily check-in.
  ///
  /// The draft state and a stable check-in id are retained for the lifetime of the
  /// container (keepAlive) so going backward or retrying a save preserves answers
  /// and never creates a duplicate check-in. Persistence is local-first.
  CheckInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInControllerHash();

  @$internal
  @override
  CheckInController create() => CheckInController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInFormState>(value),
    );
  }
}

String _$checkInControllerHash() => r'0898fbc4c584e87df5d1cdf0f878ea80a5944001';

/// Captures and persists the five-step daily check-in.
///
/// The draft state and a stable check-in id are retained for the lifetime of the
/// container (keepAlive) so going backward or retrying a save preserves answers
/// and never creates a duplicate check-in. Persistence is local-first.

abstract class _$CheckInController extends $Notifier<CheckInFormState> {
  CheckInFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckInFormState, CheckInFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckInFormState, CheckInFormState>,
              CheckInFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
