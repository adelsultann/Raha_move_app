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

@ProviderFor(streakProgress)
final streakProgressProvider = StreakProgressProvider._();

final class StreakProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakProgress>,
          StreakProgress,
          FutureOr<StreakProgress>
        >
    with $FutureModifier<StreakProgress>, $FutureProvider<StreakProgress> {
  StreakProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakProgressHash();

  @$internal
  @override
  $FutureProviderElement<StreakProgress> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StreakProgress> create(Ref ref) {
    return streakProgress(ref);
  }
}

String _$streakProgressHash() => r'0503c79d28fbac1d6da09e7dc6e9591a2a801284';

@ProviderFor(achievementProgress)
final achievementProgressProvider = AchievementProgressProvider._();

final class AchievementProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementProgress>>,
          List<AchievementProgress>,
          FutureOr<List<AchievementProgress>>
        >
    with
        $FutureModifier<List<AchievementProgress>>,
        $FutureProvider<List<AchievementProgress>> {
  AchievementProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<AchievementProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AchievementProgress>> create(Ref ref) {
    return achievementProgress(ref);
  }
}

String _$achievementProgressHash() =>
    r'4cf5fa3c891019049563998ea774a9febf2dcbbb';
