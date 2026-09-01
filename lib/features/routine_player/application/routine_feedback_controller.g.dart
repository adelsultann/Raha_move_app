// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Submits a single, optional post-routine feedback response for a completed
/// session (RAHA-053).
///
/// Submission persists locally first (atomically with its outbox operation) and
/// emits exactly one `feedback_submitted` analytics event carrying only the
/// allowlisted categorical rating and the stable session/routine ids. A failed
/// save keeps the selected rating so the user can retry without re-choosing;
/// skip leaves without saving anything.
///
/// Persist-once is durable: on init the controller reads any already-stored
/// response and moves straight to a terminal [RoutineFeedbackSaved] state
/// without emitting, and the data boundary never overwrites an existing
/// response. Re-opening the completion UI therefore shows the stored answer and
/// never re-submits or re-emits.

@ProviderFor(RoutineFeedbackController)
final routineFeedbackControllerProvider = RoutineFeedbackControllerFamily._();

/// Submits a single, optional post-routine feedback response for a completed
/// session (RAHA-053).
///
/// Submission persists locally first (atomically with its outbox operation) and
/// emits exactly one `feedback_submitted` analytics event carrying only the
/// allowlisted categorical rating and the stable session/routine ids. A failed
/// save keeps the selected rating so the user can retry without re-choosing;
/// skip leaves without saving anything.
///
/// Persist-once is durable: on init the controller reads any already-stored
/// response and moves straight to a terminal [RoutineFeedbackSaved] state
/// without emitting, and the data boundary never overwrites an existing
/// response. Re-opening the completion UI therefore shows the stored answer and
/// never re-submits or re-emits.
final class RoutineFeedbackControllerProvider
    extends $NotifierProvider<RoutineFeedbackController, RoutineFeedbackState> {
  /// Submits a single, optional post-routine feedback response for a completed
  /// session (RAHA-053).
  ///
  /// Submission persists locally first (atomically with its outbox operation) and
  /// emits exactly one `feedback_submitted` analytics event carrying only the
  /// allowlisted categorical rating and the stable session/routine ids. A failed
  /// save keeps the selected rating so the user can retry without re-choosing;
  /// skip leaves without saving anything.
  ///
  /// Persist-once is durable: on init the controller reads any already-stored
  /// response and moves straight to a terminal [RoutineFeedbackSaved] state
  /// without emitting, and the data boundary never overwrites an existing
  /// response. Re-opening the completion UI therefore shows the stored answer and
  /// never re-submits or re-emits.
  RoutineFeedbackControllerProvider._({
    required RoutineFeedbackControllerFamily super.from,
    required RoutineFeedbackArgs super.argument,
  }) : super(
         retry: null,
         name: r'routineFeedbackControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routineFeedbackControllerHash();

  @override
  String toString() {
    return r'routineFeedbackControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoutineFeedbackController create() => RoutineFeedbackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineFeedbackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineFeedbackState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RoutineFeedbackControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routineFeedbackControllerHash() =>
    r'c88847398f6b119645d11a356c6866e0a4ea9573';

/// Submits a single, optional post-routine feedback response for a completed
/// session (RAHA-053).
///
/// Submission persists locally first (atomically with its outbox operation) and
/// emits exactly one `feedback_submitted` analytics event carrying only the
/// allowlisted categorical rating and the stable session/routine ids. A failed
/// save keeps the selected rating so the user can retry without re-choosing;
/// skip leaves without saving anything.
///
/// Persist-once is durable: on init the controller reads any already-stored
/// response and moves straight to a terminal [RoutineFeedbackSaved] state
/// without emitting, and the data boundary never overwrites an existing
/// response. Re-opening the completion UI therefore shows the stored answer and
/// never re-submits or re-emits.

final class RoutineFeedbackControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RoutineFeedbackController,
          RoutineFeedbackState,
          RoutineFeedbackState,
          RoutineFeedbackState,
          RoutineFeedbackArgs
        > {
  RoutineFeedbackControllerFamily._()
    : super(
        retry: null,
        name: r'routineFeedbackControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Submits a single, optional post-routine feedback response for a completed
  /// session (RAHA-053).
  ///
  /// Submission persists locally first (atomically with its outbox operation) and
  /// emits exactly one `feedback_submitted` analytics event carrying only the
  /// allowlisted categorical rating and the stable session/routine ids. A failed
  /// save keeps the selected rating so the user can retry without re-choosing;
  /// skip leaves without saving anything.
  ///
  /// Persist-once is durable: on init the controller reads any already-stored
  /// response and moves straight to a terminal [RoutineFeedbackSaved] state
  /// without emitting, and the data boundary never overwrites an existing
  /// response. Re-opening the completion UI therefore shows the stored answer and
  /// never re-submits or re-emits.

  RoutineFeedbackControllerProvider call(RoutineFeedbackArgs args) =>
      RoutineFeedbackControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'routineFeedbackControllerProvider';
}

/// Submits a single, optional post-routine feedback response for a completed
/// session (RAHA-053).
///
/// Submission persists locally first (atomically with its outbox operation) and
/// emits exactly one `feedback_submitted` analytics event carrying only the
/// allowlisted categorical rating and the stable session/routine ids. A failed
/// save keeps the selected rating so the user can retry without re-choosing;
/// skip leaves without saving anything.
///
/// Persist-once is durable: on init the controller reads any already-stored
/// response and moves straight to a terminal [RoutineFeedbackSaved] state
/// without emitting, and the data boundary never overwrites an existing
/// response. Re-opening the completion UI therefore shows the stored answer and
/// never re-submits or re-emits.

abstract class _$RoutineFeedbackController
    extends $Notifier<RoutineFeedbackState> {
  late final _$args = ref.$arg as RoutineFeedbackArgs;
  RoutineFeedbackArgs get args => _$args;

  RoutineFeedbackState build(RoutineFeedbackArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RoutineFeedbackState, RoutineFeedbackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutineFeedbackState, RoutineFeedbackState>,
              RoutineFeedbackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
