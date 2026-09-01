import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/routine_feedback.dart';
import 'routine_feedback_state.dart';
import 'routine_player_providers.dart';

part 'routine_feedback_controller.freezed.dart';
part 'routine_feedback_controller.g.dart';

/// Stable identifiers for one post-routine feedback flow (no transient extras).
@freezed
abstract class RoutineFeedbackArgs with _$RoutineFeedbackArgs {
  const factory RoutineFeedbackArgs({
    required String sessionId,
    required String routineId,
  }) = _RoutineFeedbackArgs;
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
@riverpod
class RoutineFeedbackController extends _$RoutineFeedbackController {
  RoutineFeedbackArgs _args = const RoutineFeedbackArgs(
    sessionId: '',
    routineId: '',
  );

  @override
  RoutineFeedbackState build(RoutineFeedbackArgs args) {
    _args = args;
    unawaited(_loadExisting());
    return const RoutineFeedbackState.loading();
  }

  /// Reads any stored response for this session. A stored answer becomes the
  /// terminal saved state without emitting analytics; otherwise the flow is
  /// ready for a first-time choice.
  Future<void> _loadExisting() async {
    final existing = await _findExisting();
    if (existing != null) {
      state = RoutineFeedbackState.saved(rating: existing);
    } else {
      state = const RoutineFeedbackState.idle();
    }
  }

  /// Persists [rating]. Only valid from the idle state: a repeated submit after
  /// a save (or while saving) is ignored, and a failed save is retried with the
  /// preserved rating through [retry] — never with a new selection.
  Future<void> submit(FeedbackRating rating) async {
    if (state is! RoutineFeedbackIdle) return;
    await _persist(rating);
  }

  /// Re-attempts the last failed save, preserving the previously selected
  /// rating. Only valid from [RoutineFeedbackError].
  Future<void> retry() async {
    final current = state;
    if (current is! RoutineFeedbackError) return;
    await _persist(current.rating);
  }

  Future<void> _persist(FeedbackRating rating) async {
    state = RoutineFeedbackState.saving(rating: rating);
    final userId = await _resolveUserId();
    if (userId == null) {
      state = RoutineFeedbackState.error(rating: rating);
      return;
    }

    final bool wrote;
    try {
      wrote = await ref
          .read(routineFeedbackRepositoryProvider)
          .save(userId: userId, sessionId: _args.sessionId, rating: rating);
    } catch (_) {
      state = RoutineFeedbackState.error(rating: rating);
      return;
    }

    if (wrote) {
      state = RoutineFeedbackState.saved(rating: rating);
      _emitSubmitted(rating);
      return;
    }

    // A response already existed (defensive race). Show the stored answer as a
    // terminal state without emitting or overwriting.
    final stored = await _findExisting();
    state = RoutineFeedbackState.saved(rating: stored ?? rating);
  }

  Future<FeedbackRating?> _findExisting() async {
    final userId = await _resolveUserId();
    if (userId == null) return null;
    try {
      return await ref
          .read(routineFeedbackRepositoryProvider)
          .find(userId: userId, sessionId: _args.sessionId);
    } catch (_) {
      // A read failure is not a save failure; the user can still attempt a
      // first-time submit which will surface any real error.
      return null;
    }
  }

  Future<String?> _resolveUserId() async {
    final auth = await ref.read(authControllerProvider.future);
    return auth.activeUserId;
  }

  void _emitSubmitted(FeedbackRating rating) {
    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: AnalyticsEventName.feedbackSubmitted,
            properties: <String, Object?>{
              AnalyticsPropertyKey.feedbackRating: rating.key,
              AnalyticsPropertyKey.sessionId: _args.sessionId,
              AnalyticsPropertyKey.routineId: _args.routineId,
            },
          ),
        );
  }
}
