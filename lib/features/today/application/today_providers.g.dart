// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todayRepository)
final todayRepositoryProvider = TodayRepositoryProvider._();

final class TodayRepositoryProvider
    extends
        $FunctionalProvider<TodayRepository, TodayRepository, TodayRepository>
    with $Provider<TodayRepository> {
  TodayRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodayRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodayRepository create(Ref ref) {
    return todayRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayRepository>(value),
    );
  }
}

String _$todayRepositoryHash() => r'2497c831b2d90435c47049237f47864dd2201f18';

@ProviderFor(todayDashboard)
final todayDashboardProvider = TodayDashboardProvider._();

final class TodayDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayDashboard>,
          TodayDashboard,
          Stream<TodayDashboard>
        >
    with $FutureModifier<TodayDashboard>, $StreamProvider<TodayDashboard> {
  TodayDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDashboardHash();

  @$internal
  @override
  $StreamProviderElement<TodayDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TodayDashboard> create(Ref ref) {
    return todayDashboard(ref);
  }
}

String _$todayDashboardHash() => r'12c1f78965be1f0af80bbf79a1fa70bfcc1c17a5';
