// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_readiness_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the RAHA-050 pre-start readiness check for one recommended routine.
///
/// It resolves the routine's ordered media, marks steps with no playable media
/// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
/// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
/// and downloads missing assets). The result tells the UI whether to start,
/// retry, free storage, or choose another routine.

@ProviderFor(RoutineReadinessController)
final routineReadinessControllerProvider = RoutineReadinessControllerFamily._();

/// Runs the RAHA-050 pre-start readiness check for one recommended routine.
///
/// It resolves the routine's ordered media, marks steps with no playable media
/// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
/// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
/// and downloads missing assets). The result tells the UI whether to start,
/// retry, free storage, or choose another routine.
final class RoutineReadinessControllerProvider
    extends
        $NotifierProvider<RoutineReadinessController, RoutineReadinessState> {
  /// Runs the RAHA-050 pre-start readiness check for one recommended routine.
  ///
  /// It resolves the routine's ordered media, marks steps with no playable media
  /// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
  /// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
  /// and downloads missing assets). The result tells the UI whether to start,
  /// retry, free storage, or choose another routine.
  RoutineReadinessControllerProvider._({
    required RoutineReadinessControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routineReadinessControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routineReadinessControllerHash();

  @override
  String toString() {
    return r'routineReadinessControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoutineReadinessController create() => RoutineReadinessController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineReadinessState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineReadinessState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RoutineReadinessControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routineReadinessControllerHash() =>
    r'22e1f85c360d6ab6e5c2cf61064a01557fc2749b';

/// Runs the RAHA-050 pre-start readiness check for one recommended routine.
///
/// It resolves the routine's ordered media, marks steps with no playable media
/// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
/// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
/// and downloads missing assets). The result tells the UI whether to start,
/// retry, free storage, or choose another routine.

final class RoutineReadinessControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RoutineReadinessController,
          RoutineReadinessState,
          RoutineReadinessState,
          RoutineReadinessState,
          String
        > {
  RoutineReadinessControllerFamily._()
    : super(
        retry: null,
        name: r'routineReadinessControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Runs the RAHA-050 pre-start readiness check for one recommended routine.
  ///
  /// It resolves the routine's ordered media, marks steps with no playable media
  /// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
  /// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
  /// and downloads missing assets). The result tells the UI whether to start,
  /// retry, free storage, or choose another routine.

  RoutineReadinessControllerProvider call(String routineId) =>
      RoutineReadinessControllerProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routineReadinessControllerProvider';
}

/// Runs the RAHA-050 pre-start readiness check for one recommended routine.
///
/// It resolves the routine's ordered media, marks steps with no playable media
/// as [RoutineReadinessStatus.missingMedia], and otherwise prepares the media
/// through the injected [RoutineMediaPreparer] (which verifies/repairs the cache
/// and downloads missing assets). The result tells the UI whether to start,
/// retry, free storage, or choose another routine.

abstract class _$RoutineReadinessController
    extends $Notifier<RoutineReadinessState> {
  late final _$args = ref.$arg as String;
  String get routineId => _$args;

  RoutineReadinessState build(String routineId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RoutineReadinessState, RoutineReadinessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutineReadinessState, RoutineReadinessState>,
              RoutineReadinessState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
