// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foundation_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(foundationStatus)
final foundationStatusProvider = FoundationStatusProvider._();

final class FoundationStatusProvider
    extends
        $FunctionalProvider<
          FoundationStatus,
          FoundationStatus,
          FoundationStatus
        >
    with $Provider<FoundationStatus> {
  FoundationStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foundationStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foundationStatusHash();

  @$internal
  @override
  $ProviderElement<FoundationStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoundationStatus create(Ref ref) {
    return foundationStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoundationStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoundationStatus>(value),
    );
  }
}

String _$foundationStatusHash() => r'b6235890e420f13aa48b3ac800463180117e1c91';
