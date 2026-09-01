import 'dart:async';
import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/media/application/media_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/playback_plan.dart';
import '../domain/playback_session.dart';
import '../domain/playback_support.dart';
import '../domain/playback_ticker.dart';
import '../domain/routine_session_repository.dart';
import 'routine_player_providers.dart';
import 'routine_player_state.dart';

part 'routine_player_controller.freezed.dart';
part 'routine_player_controller.g.dart';

/// Identifies one routine player entry by stable IDs only (no transient extras).
/// [sessionId] selects restore mode; a null [sessionId] starts a new session.
@freezed
abstract class RoutinePlayerArgs with _$RoutinePlayerArgs {
  const factory RoutinePlayerArgs({
    required String routineId,
    String? recommendationId,
    String? sessionId,
  }) = _RoutinePlayerArgs;
}

/// The deterministic state machine for one focused routine playback session.
///
/// It owns the in-memory [RoutinePlaybackSession] and mutates it on each tick
/// and user action. Durable persistence is delegated to
/// [RoutineSessionRepository]: starts and step transitions are committed
/// atomically with their outbox operation, while per-tick cursor advances are
/// local-only. Restore re-enters the player paused and never re-emits
/// `routine_started`.
@riverpod
class RoutinePlayerController extends _$RoutinePlayerController {
  RoutinePlaybackPlan? _plan;
  RoutinePlaybackSession? _session;
  DateTime? _sessionStartedAt;
  RoutinePlayerArgs _args = const RoutinePlayerArgs(routineId: '');
  RoutineSessionSnapshot? _conflict;
  bool _startChecked = false;
  final Set<String> _emittedTerminalSessionIds = {};
  Future<void> Function()? _pendingSave;

  @override
  RoutinePlayerState build(RoutinePlayerArgs args) {
    final ticker = ref.watch(playbackTickerProvider);
    final wakeLock = ref.watch(screenWakeLockProvider);
    final feedback = ref.watch(transitionFeedbackProvider);
    _ticker = ticker;
    _wakeLock = wakeLock;
    _feedback = feedback;
    _clock = ref.read(routinePlayerClockProvider);
    _args = args;

    if (args.sessionId != null) return _buildRestore(args);
    return _buildNewStart(args);
  }

  late PlaybackTicker _ticker;
  late ScreenWakeLock _wakeLock;
  late TransitionFeedback _feedback;
  late DateTime Function() _clock;

  // ---------------------------------------------------------------------------
  // Build paths
  // ---------------------------------------------------------------------------

  RoutinePlayerState _buildNewStart(RoutinePlayerArgs args) {
    final planAsync = ref.watch(routinePlaybackPlanProvider(args.routineId));
    final resumableAsync = ref.watch(resumableRoutineSessionProvider);
    return planAsync.when(
      loading: () => const RoutinePlayerLoading(),
      error: (_, _) => const RoutinePlayerFailed(),
      data: (plan) => resumableAsync.when(
        loading: () => const RoutinePlayerLoading(),
        error: (_, _) => const RoutinePlayerFailed(),
        data: (resumable) {
          _plan = plan;
          if (resumable != null) {
            _conflict = resumable;
            return RoutinePlayerConflict(resumable: resumable);
          }
          if (!_startChecked) {
            _startChecked = true;
            _startSession(args, plan);
          }
          return RoutinePlayerReady(session: _session!);
        },
      ),
    );
  }

  RoutinePlayerState _buildRestore(RoutinePlayerArgs args) {
    final planAsync = ref.watch(routinePlaybackPlanProvider(args.routineId));
    final sessionAsync = ref.watch(routineSessionByIdProvider(args.sessionId!));
    return planAsync.when(
      loading: () => const RoutinePlayerLoading(),
      error: (_, _) => const RoutinePlayerFailed(),
      data: (plan) => sessionAsync.when(
        loading: () => const RoutinePlayerLoading(),
        error: (_, _) => const RoutinePlayerFailed(),
        data: (snapshot) {
          if (snapshot == null || snapshot.status != 'in_progress') {
            return const RoutinePlayerFailed();
          }
          _plan = plan;
          if (_session == null) {
            _restoreSession(snapshot, plan);
          }
          return RoutinePlayerReady(session: _session!);
        },
      ),
    );
  }

  void _startSession(RoutinePlayerArgs args, RoutinePlaybackPlan plan) {
    final now = _clock().toUtc();
    _sessionStartedAt = now;
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
    unawaited(_guardedPersist(_session!, terminal: false));
  }

  void _restoreSession(
    RoutineSessionSnapshot snapshot,
    RoutinePlaybackPlan plan,
  ) {
    _sessionStartedAt = snapshot.startedAt;
    _session = _mapSnapshotToSession(snapshot, plan);
    // Restore is always paused and user-controlled; it never emits
    // routine_started and never auto-resumes playback.
  }

  // ---------------------------------------------------------------------------
  // User actions
  // ---------------------------------------------------------------------------

  void togglePause() {
    final session = _session;
    if (session == null) return;
    switch (session.status) {
      case PlaybackStatus.playing:
        pause();
      case PlaybackStatus.paused:
        resume();
      case PlaybackStatus.completed:
      case PlaybackStatus.abandoned:
        break;
    }
  }

  void pause() {
    final session = _session;
    if (session == null || session.status != PlaybackStatus.playing) return;
    final paused = session.copyWith(status: PlaybackStatus.paused);
    _setSession(paused);
    _pausePlayback();
    unawaited(_persistCursor(paused));
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
    if (session == null || session.isTerminal) return;
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
    if (session == null || session.isTerminal) return;
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
    if (session == null || session.isTerminal) return;
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
    final updated = session.copyWith(
      steps: steps,
      currentStepIndex: newIndex,
      status: PlaybackStatus.playing,
    );
    _setSession(updated);
    _resumePlayback();
    unawaited(_guardedPersist(updated, terminal: false));
  }

  /// Explicitly ends an unfinished session: remaining pending steps terminalize
  /// (the active step keeps its credited partial time, the rest are skipped)
  /// and the session becomes abandoned, never completed. Returns true when the
  /// abandonment was durably persisted (or was already terminal).
  Future<bool> abandon() async {
    final session = _session;
    if (session == null || session.isTerminal) return true;
    final terminal = session.copyWith(
      status: PlaybackStatus.abandoned,
      steps: _terminalizePendingForAbandon(session),
    );
    _setSession(terminal);
    _pausePlayback();
    final ok = await _persist(
      terminal,
      terminal: true,
      explicitlyAbandoned: true,
    );
    if (!ok) {
      _failPersist(
        () => _retrySessionPersist(
          terminal,
          terminal: true,
          explicitlyAbandoned: true,
        ),
      );
      return false;
    }
    _emitTerminalFor(
      sessionId: terminal.sessionId,
      routineId: terminal.routineId,
      recommendationId: terminal.recommendationId,
      status: PlaybackStatus.abandoned,
    );
    return true;
  }

  /// Resolves a conflicting in-progress session: abandons it durably, then
  /// starts the newly requested routine as a fresh session. Emits exactly one
  /// `routine_abandoned` event for the abandoned snapshot.
  Future<void> abandonAndStart() async {
    final conflict = _conflict;
    if (conflict == null) return;
    final ok = await _persistAbandonSnapshot(conflict);
    if (!ok) {
      _pendingSave = () => abandonAndStart();
      _pausePlayback();
      state = const RoutinePlayerSaveError();
      return;
    }
    _conflict = null;
    _emitTerminalFor(
      sessionId: conflict.sessionId,
      routineId: conflict.routineId,
      recommendationId: conflict.recommendationId,
      status: PlaybackStatus.abandoned,
    );
    final plan = _plan;
    if (plan == null) return;
    _startSession(_args, plan);
    state = RoutinePlayerReady(session: _session!);
  }

  /// Re-attempts the last failed durable write. On success restores the ready
  /// (or terminal) state; on a repeated failure it stays in the save-error
  /// state for another retry. The repository upserts by session id, so retries
  /// never create a duplicate session.
  Future<void> retrySave() async {
    final retry = _pendingSave;
    if (retry == null) return;
    _pendingSave = null;
    await retry();
  }

  /// Stops playback resources for the close/exit affordance. Idempotent.
  void finish() {
    _pausePlayback();
  }

  // ---------------------------------------------------------------------------
  // Internal transitions and persistence
  // ---------------------------------------------------------------------------

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
    final updated = session.copyWith(steps: steps);
    _setSession(updated);

    if (newCredited >= current.durationSeconds) {
      _advance();
    } else {
      unawaited(_persistCursor(updated));
    }
  }

  void _setSession(RoutinePlaybackSession session) {
    _session = session;
    state = RoutinePlayerReady(session: session);
  }

  void _advance() {
    final session = _session;
    if (session == null || session.isTerminal) return;
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
    final updated = session.copyWith(steps: steps, currentStepIndex: newIndex);
    _setSession(updated);
    _feedback.onStepTransition();
    _preloadNext(newIndex);
    unawaited(_guardedPersist(updated, terminal: false));
  }

  void _complete() {
    final session = _session;
    if (session == null || session.isTerminal) return;
    final status = _terminalStatusFor(session);
    final terminal = session.copyWith(status: status);
    _setSession(terminal);
    _pausePlayback();
    unawaited(_guardedPersist(terminal, terminal: true));
    _emitTerminalFor(
      sessionId: terminal.sessionId,
      routineId: terminal.routineId,
      recommendationId: terminal.recommendationId,
      status: status,
    );
  }

  PlaybackStatus _terminalStatusFor(RoutinePlaybackSession session) {
    final qualifies = qualifiesForCompletion(
      actualDurationSeconds: session.totalCreditedSeconds,
      targetDurationSeconds: session.totalDurationSeconds,
      stepsSkipped: session.stepsSkipped,
      totalSteps: session.steps.length,
    );
    return qualifies ? PlaybackStatus.completed : PlaybackStatus.abandoned;
  }

  List<RoutineStepPlayback> _terminalizePendingForAbandon(
    RoutinePlaybackSession session,
  ) {
    final current = session.currentStep;
    return [
      for (final step in session.steps)
        if (step.state != StepPlaybackState.pending)
          step
        else if (identical(step, current) && step.creditedSeconds > 0)
          step.copyWith(state: StepPlaybackState.partial)
        else
          step.copyWith(
            state: StepPlaybackState.skipped,
            creditedSeconds: 0,
            skipRequested: true,
          ),
    ];
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

  // ---------------------------------------------------------------------------
  // Durable persistence helpers
  // ---------------------------------------------------------------------------

  Future<String?> _resolveUserId() async {
    final auth = await ref.read(authControllerProvider.future);
    return auth.activeUserId;
  }

  Future<bool> _persist(
    RoutinePlaybackSession session, {
    required bool terminal,
    bool explicitlyAbandoned = false,
  }) async {
    try {
      final repository = ref.read(routineSessionRepositoryProvider);
      final userId = await _resolveUserId();
      if (userId == null) return false;
      await repository.save(
        userId: userId,
        sessionId: session.sessionId,
        routineId: session.routineId,
        routineVersion: session.routineVersion,
        recommendationId: session.recommendationId,
        startedAt: _sessionStartedAt ?? _clock().toUtc(),
        steps: [
          for (var i = 0; i < session.steps.length; i++)
            _toStepSnapshot(session.steps[i], position: i + 1),
        ],
        currentStepPosition: terminal ? null : session.currentStepIndex + 1,
        currentStepActiveSeconds: terminal
            ? null
            : session.currentStep.creditedSeconds,
        explicitlyAbandoned: explicitlyAbandoned,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fire-and-forget wrapper: a failed authoritative session write becomes a
  /// recoverable save-error state instead of an unhandled exception.
  Future<void> _guardedPersist(
    RoutinePlaybackSession session, {
    required bool terminal,
    bool explicitlyAbandoned = false,
  }) async {
    final ok = await _persist(
      session,
      terminal: terminal,
      explicitlyAbandoned: explicitlyAbandoned,
    );
    if (!ok) {
      _failPersist(
        () => _retrySessionPersist(
          session,
          terminal: terminal,
          explicitlyAbandoned: explicitlyAbandoned,
        ),
      );
    }
  }

  Future<void> _retrySessionPersist(
    RoutinePlaybackSession session, {
    required bool terminal,
    bool explicitlyAbandoned = false,
  }) async {
    final ok = await _persist(
      session,
      terminal: terminal,
      explicitlyAbandoned: explicitlyAbandoned,
    );
    if (!ok) {
      _failPersist(
        () => _retrySessionPersist(
          session,
          terminal: terminal,
          explicitlyAbandoned: explicitlyAbandoned,
        ),
      );
      return;
    }
    _restoreReady(session);
  }

  Future<void> _persistCursor(RoutinePlaybackSession session) async {
    try {
      final repository = ref.read(routineSessionRepositoryProvider);
      final userId = await _resolveUserId();
      if (userId == null) return;
      await repository.saveCursor(
        userId: userId,
        sessionId: session.sessionId,
        currentStepPosition: session.currentStepIndex + 1,
        activeSeconds: session.currentStep.creditedSeconds,
      );
    } catch (_) {
      // Cursor writes are local-only and may be safely ignored on failure.
    }
  }

  Future<bool> _persistAbandonSnapshot(RoutineSessionSnapshot snapshot) async {
    try {
      final repository = ref.read(routineSessionRepositoryProvider);
      final userId = await _resolveUserId();
      if (userId == null) return false;
      final steps = [
        for (final step in snapshot.steps)
          if (step.status != 'pending')
            step
          else if (step.position == snapshot.currentStepPosition &&
              (snapshot.currentStepActiveSeconds ?? 0) > 0)
            step.copyWith(
              status: 'partial',
              activeDurationSeconds: snapshot.currentStepActiveSeconds!,
            )
          else
            step.copyWith(
              status: 'skipped',
              activeDurationSeconds: 0,
              skipRequested: true,
            ),
      ];
      await repository.save(
        userId: userId,
        sessionId: snapshot.sessionId,
        routineId: snapshot.routineId,
        routineVersion: snapshot.routineVersion,
        recommendationId: snapshot.recommendationId,
        startedAt: snapshot.startedAt,
        steps: steps,
        explicitlyAbandoned: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void _failPersist(Future<void> Function() retry) {
    _pendingSave = retry;
    _pausePlayback();
    state = const RoutinePlayerSaveError();
  }

  void _restoreReady(RoutinePlaybackSession session) {
    _session = session;
    state = RoutinePlayerReady(session: session);
    if (session.isTerminal) {
      _emitTerminalFor(
        sessionId: session.sessionId,
        routineId: session.routineId,
        recommendationId: session.recommendationId,
        status: session.status,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  RoutinePlaybackSession _mapSnapshotToSession(
    RoutineSessionSnapshot snapshot,
    RoutinePlaybackPlan plan,
  ) {
    final planByName = {for (final step in plan.steps) step.stepId: step};
    final activePosition = snapshot.currentStepPosition;
    final activeSeconds = snapshot.currentStepActiveSeconds ?? 0;
    final steps = <RoutineStepPlayback>[
      for (final step in snapshot.steps)
        _mapStepFromSnapshot(step, planByName, activePosition, activeSeconds),
    ];
    return RoutinePlaybackSession(
      sessionId: snapshot.sessionId,
      routineId: snapshot.routineId,
      routineVersion: snapshot.routineVersion,
      routineName: plan.routineName,
      recommendationId: snapshot.recommendationId,
      status: PlaybackStatus.paused,
      currentStepIndex: (activePosition ?? 1) - 1,
      steps: steps,
    );
  }

  RoutineStepPlayback _mapStepFromSnapshot(
    RoutineStepSnapshot step,
    Map<String, RoutineStepPlan> planByName,
    int? activePosition,
    int activeSeconds,
  ) {
    final planStep = planByName[step.stepId];
    final isActive = step.position == activePosition;
    return RoutineStepPlayback(
      stepId: step.stepId,
      exerciseId: step.exerciseId,
      name: planStep?.name ?? '',
      shortCue: planStep?.shortCue,
      durationSeconds: step.targetDurationSeconds,
      state: isActive
          ? StepPlaybackState.pending
          : _stateFromStatus(step.status),
      creditedSeconds: isActive ? activeSeconds : step.activeDurationSeconds,
      skipRequested: step.skipRequested,
    );
  }

  RoutineStepSnapshot _toStepSnapshot(
    RoutineStepPlayback step, {
    required int position,
  }) {
    return RoutineStepSnapshot(
      stepId: step.stepId,
      exerciseId: step.exerciseId,
      position: position,
      status: _statusOf(step.state),
      targetDurationSeconds: step.durationSeconds,
      activeDurationSeconds: step.state == StepPlaybackState.pending
          ? 0
          : step.creditedSeconds,
      skipRequested: step.skipRequested,
    );
  }

  static String _statusOf(StepPlaybackState state) => switch (state) {
    StepPlaybackState.pending => 'pending',
    StepPlaybackState.completed => 'completed',
    StepPlaybackState.partial => 'partial',
    StepPlaybackState.skipped => 'skipped',
  };

  static StepPlaybackState _stateFromStatus(String status) => switch (status) {
    'completed' => StepPlaybackState.completed,
    'partial' => StepPlaybackState.partial,
    'skipped' => StepPlaybackState.skipped,
    _ => StepPlaybackState.pending,
  };

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

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

  void _emitTerminalFor({
    required String sessionId,
    required String routineId,
    String? recommendationId,
    required PlaybackStatus status,
  }) {
    if (!_emittedTerminalSessionIds.add(sessionId)) return;
    final name = status == PlaybackStatus.completed
        ? AnalyticsEventName.routineCompleted
        : AnalyticsEventName.routineAbandoned;
    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: name,
            properties: <String, Object?>{
              AnalyticsPropertyKey.routineId: routineId,
              AnalyticsPropertyKey.sessionId: sessionId,
              AnalyticsPropertyKey.source: 'recommendation',
              AnalyticsPropertyKey.recommendationId: ?recommendationId,
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
