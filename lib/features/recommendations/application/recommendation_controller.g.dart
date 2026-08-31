// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates one recommendation flow for a completed check-in, including the
/// alternative/rejection loop: it reads the check-in back from local storage,
/// loads candidates/history/preferences, runs the on-device engine, and
/// persists the top candidate. Rejecting a recommendation marks it rejected,
/// accumulates a refinement, and re-runs deterministically until no alternative
/// remains (the rejected set grows, so the loop cannot run indefinitely).

@ProviderFor(RecommendationController)
final recommendationControllerProvider = RecommendationControllerFamily._();

/// Orchestrates one recommendation flow for a completed check-in, including the
/// alternative/rejection loop: it reads the check-in back from local storage,
/// loads candidates/history/preferences, runs the on-device engine, and
/// persists the top candidate. Rejecting a recommendation marks it rejected,
/// accumulates a refinement, and re-runs deterministically until no alternative
/// remains (the rejected set grows, so the loop cannot run indefinitely).
final class RecommendationControllerProvider
    extends
        $AsyncNotifierProvider<RecommendationController, RecommendationState> {
  /// Orchestrates one recommendation flow for a completed check-in, including the
  /// alternative/rejection loop: it reads the check-in back from local storage,
  /// loads candidates/history/preferences, runs the on-device engine, and
  /// persists the top candidate. Rejecting a recommendation marks it rejected,
  /// accumulates a refinement, and re-runs deterministically until no alternative
  /// remains (the rejected set grows, so the loop cannot run indefinitely).
  RecommendationControllerProvider._({
    required RecommendationControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recommendationControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendationControllerHash();

  @override
  String toString() {
    return r'recommendationControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecommendationController create() => RecommendationController();

  @override
  bool operator ==(Object other) {
    return other is RecommendationControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationControllerHash() =>
    r'cfa0ab11c5aee28ee179c75c6d4b41709f0ec14e';

/// Orchestrates one recommendation flow for a completed check-in, including the
/// alternative/rejection loop: it reads the check-in back from local storage,
/// loads candidates/history/preferences, runs the on-device engine, and
/// persists the top candidate. Rejecting a recommendation marks it rejected,
/// accumulates a refinement, and re-runs deterministically until no alternative
/// remains (the rejected set grows, so the loop cannot run indefinitely).

final class RecommendationControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RecommendationController,
          AsyncValue<RecommendationState>,
          RecommendationState,
          FutureOr<RecommendationState>,
          String
        > {
  RecommendationControllerFamily._()
    : super(
        retry: null,
        name: r'recommendationControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Orchestrates one recommendation flow for a completed check-in, including the
  /// alternative/rejection loop: it reads the check-in back from local storage,
  /// loads candidates/history/preferences, runs the on-device engine, and
  /// persists the top candidate. Rejecting a recommendation marks it rejected,
  /// accumulates a refinement, and re-runs deterministically until no alternative
  /// remains (the rejected set grows, so the loop cannot run indefinitely).

  RecommendationControllerProvider call(String checkInId) =>
      RecommendationControllerProvider._(argument: checkInId, from: this);

  @override
  String toString() => r'recommendationControllerProvider';
}

/// Orchestrates one recommendation flow for a completed check-in, including the
/// alternative/rejection loop: it reads the check-in back from local storage,
/// loads candidates/history/preferences, runs the on-device engine, and
/// persists the top candidate. Rejecting a recommendation marks it rejected,
/// accumulates a refinement, and re-runs deterministically until no alternative
/// remains (the rejected set grows, so the loop cannot run indefinitely).

abstract class _$RecommendationController
    extends $AsyncNotifier<RecommendationState> {
  late final _$args = ref.$arg as String;
  String get checkInId => _$args;

  FutureOr<RecommendationState> build(String checkInId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<RecommendationState>, RecommendationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecommendationState>, RecommendationState>,
              AsyncValue<RecommendationState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
