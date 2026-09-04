// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_routines_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedRoutinesRepository)
final savedRoutinesRepositoryProvider = SavedRoutinesRepositoryProvider._();

final class SavedRoutinesRepositoryProvider
    extends
        $FunctionalProvider<
          SavedRoutinesRepository,
          SavedRoutinesRepository,
          SavedRoutinesRepository
        >
    with $Provider<SavedRoutinesRepository> {
  SavedRoutinesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutinesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutinesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedRoutinesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedRoutinesRepository create(Ref ref) {
    return savedRoutinesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRoutinesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRoutinesRepository>(value),
    );
  }
}

String _$savedRoutinesRepositoryHash() =>
    r'ceb247e30893f5d0fe0fdfba5f5029fd335cce33';

@ProviderFor(savedRoutinesLocale)
final savedRoutinesLocaleProvider = SavedRoutinesLocaleProvider._();

final class SavedRoutinesLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  SavedRoutinesLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutinesLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutinesLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return savedRoutinesLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$savedRoutinesLocaleHash() =>
    r'907c5eb847db13994e0611b78e767ac4e9dda381';

@ProviderFor(savedRoutines)
final savedRoutinesProvider = SavedRoutinesProvider._();

final class SavedRoutinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedRoutine>>,
          List<SavedRoutine>,
          FutureOr<List<SavedRoutine>>
        >
    with
        $FutureModifier<List<SavedRoutine>>,
        $FutureProvider<List<SavedRoutine>> {
  SavedRoutinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRoutinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRoutinesHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedRoutine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedRoutine>> create(Ref ref) {
    return savedRoutines(ref);
  }
}

String _$savedRoutinesHash() => r'48836d3b063becfd1239cabba852eb0d76bcfc62';
