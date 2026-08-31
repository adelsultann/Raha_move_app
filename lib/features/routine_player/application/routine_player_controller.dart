import 'dart:async';
import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/media/application/media_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/playback_plan.dart';
import '../domain/playback_session.dart';
import '../domain/playback_support.dart';
import '../domain/playback_ticker.dart';
import 'routine_player_providers.dart';
import 'routine_player_state.dart';

part 'routine_player_controller.freezed.dart';
part 'routine_player_controller.g.dart';

/// Identifies one routine player entry by stable IDs only (no transient extras).
@freezed
abstract class RoutinePlayerArgs with _$RoutinePlayerArgs {
  const factory RoutinePlayerArgs({
    required String routineId,
    String? recommendationId,
  }) = _RoutinePlayerArgs;
}

/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence, restore, and completion-policy
/// evaluation are out of scope (RAHA-052); this controller only keeps the
/// session model correct in memory.
@riverpod
class RoutinePlayerController extends _$RoutinePlayerController {
  RoutinePlaybackPlan? _plan;
  RoutinePlaybackSession? _session;
  bool _sessionStarted = false;

  @override
  RoutinePlayerState build(RoutinePlayerArgs args) {
    final ticker = ref.watch(playbackTickerProvider);
    final wakeLock = ref.watch(screenWakeLockProvider);
    final feedback = ref.watch(transitionFeedbackProvider);
    _ticker = ticker;
    _wakeLock = wakeLock;
    _feedback = feedback;

    final planAsync = ref.watch(routinePlaybackPlanProvider(args.routineId));
    return planAsync.when(
      loading: () => const RoutinePlayerLoading(),
      error: (_, _) => const RoutinePlayerFailed(),
      data: (plan) {
        _plan = plan;
        if (!_sessionStarted) {
          _startSession(args, plan);
        }
        return RoutinePlayerReady(session: _session!);
      },
    );
  }

  late PlaybackTicker _ticker;
  late ScreenWakeLock _wakeLock;
  late TransitionFeedback _feedback;

  void _startSession(RoutinePlayerArgs args, RoutinePlaybackPlan plan) {
    _sessionStarted = true;
    _session = RoutinePlaybackSession(
      sessionId: generateUuidV4(),
      routineId: plan.routineId,
      routineVersion: plan.routineVersion,
      routineName: plan.routineName,
      recommendationId: args.recommendationId,
      status: PlaybackStatus.playing,
      currentStepIndex: 0,
      steps: [
        for (final step in plan.steps)
          RoutineStepPlayback(
            stepId: step.stepId,
            exerciseId: step.exerciseId,
            name: step.name,
            shortCue: step.shortCue,
            durationSeconds: step.durationSeconds,
            state: StepPlaybackState.pending,
            creditedSeconds: 0,
            skipRequested: false,
          ),
      ],
    );
    _resumePlayback();
    _emitRoutineStarted();
  }

  void _onTick() {
    final session = _session;
    if (session == null || session.status != PlaybackStatus.playing) return;

    final index = session.currentStepIndex;
    final current = session.steps[index];
    final newCredited = math.min(
      current.creditedSeconds + 1,
      current.durationSeconds,
    );
    if (newCredited == current.creditedSeconds) return;

    final steps = _updateStep(
      session.steps,
      index,
      (step) => step.copyWith(
        creditedSeconds: newCredited,
        state: newCredited >= current.durationSeconds
            ? StepPlaybackState.completed
            : step.state,
      ),
    );
    _setSession(session.copyWith(steps: steps));

    if (newCredited >= current.durationSeconds) {
      _advance();
    }
  }

  void _setSession(RoutinePlaybackSession session) {
    _session = session;
    state = RoutinePlayerReady(session: session);
  }

  void togglePause() {
    final session = _session;
    if (session == null) return;
    switch (session.status) {
      case PlaybackStatus.playing:
        pause();
      case PlaybackStatus.paused:
        resume();
      case PlaybackStatus.completed:
        break;
    }
  }

  void pause() {
    final session = _session;
    if (session == null || session.status != PlaybackStatus.playing) return;
    _setSession(session.copyWith(status: PlaybackStatus.paused));
    _pausePlayback();
  }

  void resume() {
    final session = _session;
    if (session == null || session.status != PlaybackStatus.paused) return;
    _setSession(session.copyWith(status: PlaybackStatus.playing));
    _resumePlayback();
  }

  /// Pauses on backgrounding. The player stays paused and the user resumes
  /// manually; it never silently auto-resumes.
  void pauseForBackground() => pause();

  void skip() {
    final session = _session;
    if (session == null || session.status == PlaybackStatus.completed) return;
    final index = session.currentStepIndex;
    final current = session.steps[index];
    final terminal = terminalStateFor(
      creditedSeconds: current.creditedSeconds,
      durationSeconds: current.durationSeconds,
      skipRequested: true,
    );
    _setSession(
      session.copyWith(
        steps: _updateStep(
          session.steps,
          index,
          (step) => step.copyWith(state: terminal, skipRequested: true),
        ),
      ),
    );
    _advance();
  }

  void next() {
    final session = _session;
    if (session == null || session.status == PlaybackStatus.completed) return;
    final index = session.currentStepIndex;
    final current = session.steps[index];
    final terminal = terminalStateFor(
      creditedSeconds: current.creditedSeconds,
      durationSeconds: current.durationSeconds,
      skipRequested: false,
    );
    _setSession(
      session.copyWith(
        steps: _updateStep(
          session.steps,
          index,
          (step) => step.copyWith(state: terminal),
        ),
      ),
    );
    _advance();
  }

  void previous() {
    final session = _session;
    if (session == null || session.status == PlaybackStatus.completed) return;
    if (session.currentStepIndex == 0) return;

    final index = session.currentStepIndex;
    var steps = _updateStep(
      session.steps,
      index,
      (step) => step.copyWith(
        state: StepPlaybackState.pending,
        creditedSeconds: 0,
        skipRequested: false,
      ),
    );
    final newIndex = index - 1;
    steps = _updateStep(
      steps,
      newIndex,
      (step) => step.copyWith(
        state: StepPlaybackState.pending,
        creditedSeconds: 0,
        skipRequested: false,
      ),
    );
    _setSession(
      session.copyWith(
        steps: steps,
        currentStepIndex: newIndex,
        status: PlaybackStatus.playing,
      ),
    );
    _resumePlayback();
  }

  /// Stops playback resources for the close/exit affordance. Idempotent.
  void finish() {
    _pausePlayback();
  }

  void _advance() {
    final session = _session;
    if (session == null || session.status == PlaybackStatus.completed) return;
    if (session.isLastStep) {
      _complete();
      return;
    }

    final newIndex = session.currentStepIndex + 1;
    final steps = _updateStep(
      session.steps,
      newIndex,
      (step) => step.copyWith(
        state: StepPlaybackState.pending,
        creditedSeconds: 0,
        skipRequested: false,
      ),
    );
    _setSession(session.copyWith(steps: steps, currentStepIndex: newIndex));
    _feedback.onStepTransition();
    _preloadNext(newIndex);
  }

  void _complete() {
    final session = _session;
    if (session == null) return;
    _setSession(session.copyWith(status: PlaybackStatus.completed));
    _pausePlayback();
  }

  void _resumePlayback() {
    _ticker.start(_onTick);
    unawaited(_wakeLock.enable());
  }

  void _pausePlayback() {
    _ticker.stop();
    unawaited(_wakeLock.disable());
  }

  void _preloadNext(int currentStepIndex) {
    final plan = _plan;
    if (plan == null) return;
    unawaited(_doPreload(plan, currentStepIndex));
  }

  Future<void> _doPreload(
    RoutinePlaybackPlan plan,
    int currentStepIndex,
  ) async {
    try {
      final coordinator = await ref.read(
        routineMediaPlaybackCoordinatorProvider.future,
      );
      if (coordinator == null) return;
      await coordinator.preloadAfterStep(
        plan.media,
        currentStepIndex: currentStepIndex,
      );
    } catch (_) {
      // Best-effort preload; a failure never breaks playback.
    }
  }

  void _emitRoutineStarted() {
    final session = _session;
    if (session == null) return;
    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: AnalyticsEventName.routineStarted,
            properties: <String, Object?>{
              AnalyticsPropertyKey.routineId: session.routineId,
              AnalyticsPropertyKey.sessionId: session.sessionId,
              AnalyticsPropertyKey.source: 'recommendation',
              if (session.recommendationId != null)
                AnalyticsPropertyKey.recommendationId: session.recommendationId,
            },
          ),
        );
  }

  static List<RoutineStepPlayback> _updateStep(
    List<RoutineStepPlayback> steps,
    int index,
    RoutineStepPlayback Function(RoutineStepPlayback) update,
  ) {
    final copy = [...steps];
    copy[index] = update(copy[index]);
    return copy;
  }
}
