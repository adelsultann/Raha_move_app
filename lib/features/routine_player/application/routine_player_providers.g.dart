// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the localized playback plan from the local Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.

@ProviderFor(routinePlaybackLoader)
final routinePlaybackLoaderProvider = RoutinePlaybackLoaderProvider._();

/// Loads the localized playback plan from the local Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.

final class RoutinePlaybackLoaderProvider
    extends
        $FunctionalProvider<
          RoutinePlaybackLoader,
          RoutinePlaybackLoader,
          RoutinePlaybackLoader
        >
    with $Provider<RoutinePlaybackLoader> {
  /// Loads the localized playback plan from the local Drift content cache.
  /// Tests override this with a fake to isolate orchestration from persistence.
  RoutinePlaybackLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinePlaybackLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinePlaybackLoaderHash();

  @$internal
  @override
  $ProviderElement<RoutinePlaybackLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutinePlaybackLoader create(Ref ref) {
    return routinePlaybackLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinePlaybackLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinePlaybackLoader>(value),
    );
  }
}

String _$routinePlaybackLoaderHash() =>
    r'5e8a5bf2772c16e5ae7e7d4c6168fa8fc92b0d0a';

/// The localized playback plan for one routine, re-resolved whenever the active
/// locale changes.

@ProviderFor(routinePlaybackPlan)
final routinePlaybackPlanProvider = RoutinePlaybackPlanFamily._();

/// The localized playback plan for one routine, re-resolved whenever the active
/// locale changes.

final class RoutinePlaybackPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutinePlaybackPlan>,
          RoutinePlaybackPlan,
          FutureOr<RoutinePlaybackPlan>
        >
    with
        $FutureModifier<RoutinePlaybackPlan>,
        $FutureProvider<RoutinePlaybackPlan> {
  /// The localized playback plan for one routine, re-resolved whenever the active
  /// locale changes.
  RoutinePlaybackPlanProvider._({
    required RoutinePlaybackPlanFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routinePlaybackPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routinePlaybackPlanHash();

  @override
  String toString() {
    return r'routinePlaybackPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RoutinePlaybackPlan> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutinePlaybackPlan> create(Ref ref) {
    final argument = this.argument as String;
    return routinePlaybackPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutinePlaybackPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routinePlaybackPlanHash() =>
    r'47b1c8c5dc605ab4755bd0c29d1a19afb38a2d73';

/// The localized playback plan for one routine, re-resolved whenever the active
/// locale changes.

final class RoutinePlaybackPlanFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RoutinePlaybackPlan>, String> {
  RoutinePlaybackPlanFamily._()
    : super(
        retry: null,
        name: r'routinePlaybackPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The localized playback plan for one routine, re-resolved whenever the active
  /// locale changes.

  RoutinePlaybackPlanProvider call(String routineId) =>
      RoutinePlaybackPlanProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routinePlaybackPlanProvider';
}

/// Keep-awake boundary. Tests override this with a recording fake.

@ProviderFor(screenWakeLock)
final screenWakeLockProvider = ScreenWakeLockProvider._();

/// Keep-awake boundary. Tests override this with a recording fake.

final class ScreenWakeLockProvider
    extends $FunctionalProvider<ScreenWakeLock, ScreenWakeLock, ScreenWakeLock>
    with $Provider<ScreenWakeLock> {
  /// Keep-awake boundary. Tests override this with a recording fake.
  ScreenWakeLockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenWakeLockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenWakeLockHash();

  @$internal
  @override
  $ProviderElement<ScreenWakeLock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScreenWakeLock create(Ref ref) {
    return screenWakeLock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenWakeLock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenWakeLock>(value),
    );
  }
}

String _$screenWakeLockHash() => r'35e84411612e2dd87872251306ba855b5f7ce9d5';

/// Transition sound/vibration boundary, gated by the active user's preferences.
/// Tests override this with a recording fake.

@ProviderFor(transitionFeedback)
final transitionFeedbackProvider = TransitionFeedbackProvider._();

/// Transition sound/vibration boundary, gated by the active user's preferences.
/// Tests override this with a recording fake.

final class TransitionFeedbackProvider
    extends
        $FunctionalProvider<
          TransitionFeedback,
          TransitionFeedback,
          TransitionFeedback
        >
    with $Provider<TransitionFeedback> {
  /// Transition sound/vibration boundary, gated by the active user's preferences.
  /// Tests override this with a recording fake.
  TransitionFeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transitionFeedbackProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transitionFeedbackHash();

  @$internal
  @override
  $ProviderElement<TransitionFeedback> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransitionFeedback create(Ref ref) {
    return transitionFeedback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransitionFeedback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransitionFeedback>(value),
    );
  }
}

String _$transitionFeedbackHash() =>
    r'1260a73cb08f40ca579793132cbd78ae96c67b5d';

/// A fresh one-second ticker per controller instance. Stopped on dispose.

@ProviderFor(playbackTicker)
final playbackTickerProvider = PlaybackTickerProvider._();

/// A fresh one-second ticker per controller instance. Stopped on dispose.

final class PlaybackTickerProvider
    extends $FunctionalProvider<PlaybackTicker, PlaybackTicker, PlaybackTicker>
    with $Provider<PlaybackTicker> {
  /// A fresh one-second ticker per controller instance. Stopped on dispose.
  PlaybackTickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackTickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackTickerHash();

  @$internal
  @override
  $ProviderElement<PlaybackTicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaybackTicker create(Ref ref) {
    return playbackTicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackTicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackTicker>(value),
    );
  }
}

String _$playbackTickerHash() => r'e32ae0bfdfbdff90b89396c7b09bb9275dc6beb4';
