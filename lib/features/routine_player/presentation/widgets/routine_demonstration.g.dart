// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_demonstration.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable demonstration renderer. Tests and a future video renderer
/// override this provider.

@ProviderFor(routineDemonstration)
final routineDemonstrationProvider = RoutineDemonstrationProvider._();

/// Injectable demonstration renderer. Tests and a future video renderer
/// override this provider.

final class RoutineDemonstrationProvider
    extends
        $FunctionalProvider<
          RoutineDemonstration,
          RoutineDemonstration,
          RoutineDemonstration
        >
    with $Provider<RoutineDemonstration> {
  /// Injectable demonstration renderer. Tests and a future video renderer
  /// override this provider.
  RoutineDemonstrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineDemonstrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineDemonstrationHash();

  @$internal
  @override
  $ProviderElement<RoutineDemonstration> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutineDemonstration create(Ref ref) {
    return routineDemonstration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineDemonstration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineDemonstration>(value),
    );
  }
}

String _$routineDemonstrationHash() =>
    r'cb45aca1e84800392fd989db5d9f666d157b4500';
