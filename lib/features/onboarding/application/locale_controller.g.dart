// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide active [Locale], restored from the local profile at startup.
///
/// It is the single source of truth consumed by `RahaMoveApp` so choosing a
/// language immediately applies its directionality and localized strings.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The app-wide active [Locale], restored from the local profile at startup.
///
/// It is the single source of truth consumed by `RahaMoveApp` so choosing a
/// language immediately applies its directionality and localized strings.
final class LocaleControllerProvider
    extends $AsyncNotifierProvider<LocaleController, Locale> {
  /// The app-wide active [Locale], restored from the local profile at startup.
  ///
  /// It is the single source of truth consumed by `RahaMoveApp` so choosing a
  /// language immediately applies its directionality and localized strings.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();
}

String _$localeControllerHash() => r'eba9dd4a27d352b367dfb4a469268c1e727e739d';

/// The app-wide active [Locale], restored from the local profile at startup.
///
/// It is the single source of truth consumed by `RahaMoveApp` so choosing a
/// language immediately applies its directionality and localized strings.

abstract class _$LocaleController extends $AsyncNotifier<Locale> {
  FutureOr<Locale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale>, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale>, Locale>,
              AsyncValue<Locale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
