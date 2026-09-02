// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gamificationRepository)
final gamificationRepositoryProvider = GamificationRepositoryProvider._();

final class GamificationRepositoryProvider
    extends
        $FunctionalProvider<
          GamificationRepository,
          GamificationRepository,
          GamificationRepository
        >
    with $Provider<GamificationRepository> {
  GamificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gamificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gamificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<GamificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GamificationRepository create(Ref ref) {
    return gamificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GamificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GamificationRepository>(value),
    );
  }
}

String _$gamificationRepositoryHash() =>
    r'34cc35811a473897e451cd4cd1662774661a8dfe';

/// Read-only local-first completion summary. Invalidating this provider retries
/// a transient database/profile error without creating any reward state.

@ProviderFor(weeklyGoalProgress)
final weeklyGoalProgressProvider = WeeklyGoalProgressProvider._();

/// Read-only local-first completion summary. Invalidating this provider retries
/// a transient database/profile error without creating any reward state.

final class WeeklyGoalProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyGoalProgress>,
          WeeklyGoalProgress,
          FutureOr<WeeklyGoalProgress>
        >
    with
        $FutureModifier<WeeklyGoalProgress>,
        $FutureProvider<WeeklyGoalProgress> {
  /// Read-only local-first completion summary. Invalidating this provider retries
  /// a transient database/profile error without creating any reward state.
  WeeklyGoalProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyGoalProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyGoalProgressHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyGoalProgress> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyGoalProgress> create(Ref ref) {
    return weeklyGoalProgress(ref);
  }
}

String _$weeklyGoalProgressHash() =>
    r'b7af5b5054af379605ab9da420d87b60efbb7add';
