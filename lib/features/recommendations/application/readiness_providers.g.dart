// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves one routine's ordered, playable media from the Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.

@ProviderFor(routineMediaResolver)
final routineMediaResolverProvider = RoutineMediaResolverProvider._();

/// Resolves one routine's ordered, playable media from the Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.

final class RoutineMediaResolverProvider
    extends
        $FunctionalProvider<
          RoutineMediaResolver,
          RoutineMediaResolver,
          RoutineMediaResolver
        >
    with $Provider<RoutineMediaResolver> {
  /// Resolves one routine's ordered, playable media from the Drift content cache.
  /// Tests override this with a fake to isolate orchestration from persistence.
  RoutineMediaResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineMediaResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineMediaResolverHash();

  @$internal
  @override
  $ProviderElement<RoutineMediaResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutineMediaResolver create(Ref ref) {
    return routineMediaResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineMediaResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineMediaResolver>(value),
    );
  }
}

String _$routineMediaResolverHash() =>
    r'2dd2a782077123ef7f126c1437e3b55c2a79b985';

/// The readiness preparer, backed by the media playback coordinator. Null while
/// there is no media access scope (a guest with no Supabase identity yet), which
/// the readiness controller surfaces as an unavailable/offline result.

@ProviderFor(routineMediaPreparer)
final routineMediaPreparerProvider = RoutineMediaPreparerProvider._();

/// The readiness preparer, backed by the media playback coordinator. Null while
/// there is no media access scope (a guest with no Supabase identity yet), which
/// the readiness controller surfaces as an unavailable/offline result.

final class RoutineMediaPreparerProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutineMediaPreparer?>,
          RoutineMediaPreparer?,
          FutureOr<RoutineMediaPreparer?>
        >
    with
        $FutureModifier<RoutineMediaPreparer?>,
        $FutureProvider<RoutineMediaPreparer?> {
  /// The readiness preparer, backed by the media playback coordinator. Null while
  /// there is no media access scope (a guest with no Supabase identity yet), which
  /// the readiness controller surfaces as an unavailable/offline result.
  RoutineMediaPreparerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineMediaPreparerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineMediaPreparerHash();

  @$internal
  @override
  $FutureProviderElement<RoutineMediaPreparer?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutineMediaPreparer?> create(Ref ref) {
    return routineMediaPreparer(ref);
  }
}

String _$routineMediaPreparerHash() =>
    r'b7074496266b78ef6b923bb99f86fcd9666762eb';
