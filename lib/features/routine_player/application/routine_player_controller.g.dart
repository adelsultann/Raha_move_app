// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_player_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence, restore, and completion-policy
/// evaluation are out of scope (RAHA-052); this controller only keeps the
/// session model correct in memory.

@ProviderFor(RoutinePlayerController)
final routinePlayerControllerProvider = RoutinePlayerControllerFamily._();

/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence, restore, and completion-policy
/// evaluation are out of scope (RAHA-052); this controller only keeps the
/// session model correct in memory.
final class RoutinePlayerControllerProvider
    extends $NotifierProvider<RoutinePlayerController, RoutinePlayerState> {
  /// The deterministic state machine for one focused routine playback session.
  ///
  /// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
  /// and user action. Durable persistence, restore, and completion-policy
  /// evaluation are out of scope (RAHA-052); this controller only keeps the
  /// session model correct in memory.
  RoutinePlayerControllerProvider._({
    required RoutinePlayerControllerFamily super.from,
    required RoutinePlayerArgs super.argument,
  }) : super(
         retry: null,
         name: r'routinePlayerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routinePlayerControllerHash();

  @override
  String toString() {
    return r'routinePlayerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoutinePlayerController create() => RoutinePlayerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinePlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinePlayerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RoutinePlayerControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routinePlayerControllerHash() =>
    r'a9f66ed62e4d9d2ce92916ae1b6ec6e77cde571d';

/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence, restore, and completion-policy
/// evaluation are out of scope (RAHA-052); this controller only keeps the
/// session model correct in memory.

final class RoutinePlayerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RoutinePlayerController,
          RoutinePlayerState,
          RoutinePlayerState,
          RoutinePlayerState,
          RoutinePlayerArgs
        > {
  RoutinePlayerControllerFamily._()
    : super(
        retry: null,
        name: r'routinePlayerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The deterministic state machine for one focused routine playback session.
  ///
  /// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
  /// and user action. Durable persistence, restore, and completion-policy
  /// evaluation are out of scope (RAHA-052); this controller only keeps the
  /// session model correct in memory.

  RoutinePlayerControllerProvider call(RoutinePlayerArgs args) =>
      RoutinePlayerControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'routinePlayerControllerProvider';
}

/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence, restore, and completion-policy
/// evaluation are out of scope (RAHA-052); this controller only keeps the
/// session model correct in memory.

abstract class _$RoutinePlayerController extends $Notifier<RoutinePlayerState> {
  late final _$args = ref.$arg as RoutinePlayerArgs;
  RoutinePlayerArgs get args => _$args;

  RoutinePlayerState build(RoutinePlayerArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RoutinePlayerState, RoutinePlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutinePlayerState, RoutinePlayerState>,
              RoutinePlayerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
