// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Captures and persists the user's basic preferences during setup.
///
/// The draft state is retained for the lifetime of the container so going
/// backward or returning after an interruption preserves answers. Persistence is
/// local-first; synchronization is owned by later preference-sync work.

@ProviderFor(PreferencesController)
final preferencesControllerProvider = PreferencesControllerProvider._();

/// Captures and persists the user's basic preferences during setup.
///
/// The draft state is retained for the lifetime of the container so going
/// backward or returning after an interruption preserves answers. Persistence is
/// local-first; synchronization is owned by later preference-sync work.
final class PreferencesControllerProvider
    extends $NotifierProvider<PreferencesController, PreferencesFormState> {
  /// Captures and persists the user's basic preferences during setup.
  ///
  /// The draft state is retained for the lifetime of the container so going
  /// backward or returning after an interruption preserves answers. Persistence is
  /// local-first; synchronization is owned by later preference-sync work.
  PreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesControllerHash();

  @$internal
  @override
  PreferencesController create() => PreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesFormState>(value),
    );
  }
}

String _$preferencesControllerHash() =>
    r'73275a01ac47aaf739148800af91571ac829fe0c';

/// Captures and persists the user's basic preferences during setup.
///
/// The draft state is retained for the lifetime of the container so going
/// backward or returning after an interruption preserves answers. Persistence is
/// local-first; synchronization is owned by later preference-sync work.

abstract class _$PreferencesController extends $Notifier<PreferencesFormState> {
  PreferencesFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PreferencesFormState, PreferencesFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreferencesFormState, PreferencesFormState>,
              PreferencesFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
