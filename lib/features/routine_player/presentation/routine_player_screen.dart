import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';

import '../application/routine_feedback_controller.dart';
import '../application/routine_feedback_state.dart';
import '../application/routine_player_controller.dart';
import '../application/routine_player_providers.dart';
import '../application/routine_player_state.dart';
import '../domain/playback_session.dart';
import '../domain/routine_feedback.dart';
import 'widgets/player_controls.dart';
import 'widgets/routine_demonstration.dart';

/// The focused, distraction-free routine player (RAHA-051/052). No bottom
/// navigation, ads, streak pressure, or unrelated actions appear here.
///
/// A null [sessionId] starts a new session (after resolving any conflicting
/// in-progress session); a non-null [sessionId] restores that session paused.
class RoutinePlayerScreen extends ConsumerStatefulWidget {
  const RoutinePlayerScreen({
    super.key,
    required this.routineId,
    this.recommendationId,
    this.sessionId,
  });

  final String routineId;
  final String? recommendationId;
  final String? sessionId;

  @override
  ConsumerState<RoutinePlayerScreen> createState() =>
      _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends ConsumerState<RoutinePlayerScreen>
    with WidgetsBindingObserver {
  RoutinePlayerArgs get _args => RoutinePlayerArgs(
    routineId: widget.routineId,
    recommendationId: widget.recommendationId,
    sessionId: widget.sessionId,
  );

  RoutinePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.finish();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller?.pauseForBackground();
      case AppLifecycleState.resumed:
        // Stay paused; the user resumes manually.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routinePlayerControllerProvider(_args));
    _controller = ref.read(routinePlayerControllerProvider(_args).notifier);

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      failed: () => _FailedState(
        onRetry: () {
          ref.invalidate(routinePlaybackPlanProvider(widget.routineId));
          if (widget.sessionId != null) {
            ref.invalidate(routineSessionByIdProvider(widget.sessionId!));
          }
        },
      ),
      conflict: (resumable) => _ConflictState(
        onResume: () {
          RoutinePlayerRoute(
            routineId: resumable.routineId,
            sessionId: resumable.sessionId,
          ).pushReplacement(context);
        },
        onAbandonAndStart: () async {
          await _controller?.abandonAndStart();
        },
      ),
      saveError: () => _SaveErrorState(onRetry: () => _controller?.retrySave()),
      ready: (session) =>
          _PlayerContent(session: session, controller: _controller!),
    );
  }
}

class _PlayerContent extends ConsumerWidget {
  const _PlayerContent({required this.session, required this.controller});

  final RoutinePlaybackSession session;
  final RoutinePlayerController controller;

  Future<void> _handleClose(BuildContext context) async {
    if (session.isTerminal) {
      controller.finish();
      if (context.mounted) context.pop();
      return;
    }
    final abandon = await showDialog<bool>(
      context: context,
      builder: (context) => _ExitConfirmationDialog(),
    );
    if (abandon == true) {
      final saved = await controller.abandon();
      if (saved && context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final demonstration = ref.watch(routineDemonstrationProvider);
    final isPlaying = session.status == PlaybackStatus.playing;
    final isPaused = session.status == PlaybackStatus.paused;

    if (session.isCompleted) {
      return _CompletedState(
        session: session,
        onDone: () => _handleClose(context),
      );
    }
    if (session.isAbandoned) {
      return _AbandonedState(onDone: () => _handleClose(context));
    }

    final step = session.currentStep;
    final remaining = step.durationSeconds - step.creditedSeconds;
    final hasNext = !session.isLastStep;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleClose(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                current: session.currentStepIndex + 1,
                total: session.steps.length,
                onClose: () => _handleClose(context),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: demonstration.build(context, playing: isPlaying),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        step.name,
                        key: const Key('player_movement_name'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.shortCue?.isNotEmpty == true
                          ? step.shortCue!
                          : strings.playerDefaultCue,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _formatTimer(remaining),
                        key: const Key('player_timer'),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                    ),
                    if (hasNext) ...[
                      const SizedBox(height: 8),
                      Text(
                        strings.playerUpNext(
                          session.steps[session.currentStepIndex + 1].name,
                        ),
                        key: const Key('player_up_next'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (isPaused) ...[
                      const SizedBox(height: 8),
                      Semantics(
                        key: const Key('player_paused'),
                        liveRegion: true,
                        label: strings.playerPaused,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pause_circle_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.playerPaused,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    PlayerControls(
                      isPlaying: isPlaying,
                      isLastStep: session.isLastStep,
                      onPrevious: controller.previous,
                      onTogglePause: controller.togglePause,
                      onSkip: controller.skip,
                      onFinish: controller.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExitConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      key: const Key('player_exit_dialog'),
      title: Semantics(header: true, child: Text(strings.playerExitTitle)),
      content: Text(strings.playerExitBody),
      actions: [
        TextButton(
          key: const Key('player_exit_keep_going'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.playerExitKeepGoing),
        ),
        FilledButton(
          key: const Key('player_exit_abandon'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.playerExitAbandon),
        ),
      ],
    );
  }
}

class _ConflictState extends StatelessWidget {
  const _ConflictState({
    required this.onResume,
    required this.onAbandonAndStart,
  });

  final VoidCallback onResume;
  final VoidCallback onAbandonAndStart;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    strings.playerConflictTitle,
                    key: const Key('player_conflict_title'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.playerConflictBody,
                  key: const Key('player_conflict_body'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('player_conflict_resume'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onResume,
                    child: Text(strings.playerConflictResume),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('player_conflict_abandon'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onAbandonAndStart,
                    child: Text(strings.playerConflictAbandon),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.current,
    required this.total,
    required this.onClose,
  });

  final int current;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            key: const Key('player_close'),
            tooltip: strings.playerClose,
            onPressed: onClose,
            icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              strings.playerMovementPosition(current, total),
              key: const Key('player_position'),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends ConsumerWidget {
  const _CompletedState({required this.session, required this.onDone});

  final RoutinePlaybackSession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final args = RoutineFeedbackArgs(
      sessionId: session.sessionId,
      routineId: session.routineId,
    );
    final feedbackState = ref.watch(routineFeedbackControllerProvider(args));
    final controller = ref.read(
      routineFeedbackControllerProvider(args).notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  strings.playerCompletedTitle,
                  key: const Key('player_completed'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.feedbackActiveMinutes(session.verifiedActiveMinutes),
                key: const Key('feedback_active_minutes'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _FeedbackBody(
                state: feedbackState,
                onSelect: controller.submit,
                onRetry: controller.retry,
                onSkip: onDone,
                onDone: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The feedback choices, acknowledgment, and save/error states. The completion
/// summary (title + verified active minutes) is always visible above this.
class _FeedbackBody extends StatelessWidget {
  const _FeedbackBody({
    required this.state,
    required this.onSelect,
    required this.onRetry,
    required this.onSkip,
    required this.onDone,
  });

  final RoutineFeedbackState state;
  final Future<void> Function(FeedbackRating rating) onSelect;
  final Future<void> Function() onRetry;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RoutineFeedbackLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      RoutineFeedbackIdle() => _FeedbackChoices(
        onSelect: onSelect,
        onSkip: onSkip,
      ),
      RoutineFeedbackSaving() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      RoutineFeedbackSaved(:final rating) => _FeedbackAcknowledged(
        rating: rating,
        onDone: onDone,
      ),
      RoutineFeedbackError() => _FeedbackSaveError(
        onRetry: onRetry,
        onSkip: onSkip,
      ),
    };
  }
}

class _FeedbackChoices extends StatelessWidget {
  const _FeedbackChoices({required this.onSelect, required this.onSkip});

  final Future<void> Function(FeedbackRating rating) onSelect;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            strings.feedbackQuestion,
            key: const Key('feedback_question'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        _FeedbackChoice(
          key: const Key('feedback_much_better'),
          label: strings.feedbackMuchBetter,
          onPressed: () => onSelect(FeedbackRating.muchBetter),
        ),
        const SizedBox(height: 12),
        _FeedbackChoice(
          key: const Key('feedback_little_better'),
          label: strings.feedbackLittleBetter,
          onPressed: () => onSelect(FeedbackRating.littleBetter),
        ),
        const SizedBox(height: 12),
        _FeedbackChoice(
          key: const Key('feedback_same'),
          label: strings.feedbackSame,
          onPressed: () => onSelect(FeedbackRating.same),
        ),
        const SizedBox(height: 12),
        _FeedbackChoice(
          key: const Key('feedback_less_comfortable'),
          label: strings.feedbackLessComfortable,
          onPressed: () => onSelect(FeedbackRating.lessComfortable),
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('feedback_skip'),
          onPressed: onSkip,
          child: Text(strings.feedbackSkip),
        ),
      ],
    );
  }
}

class _FeedbackChoice extends StatelessWidget {
  const _FeedbackChoice({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// Calm, restrained acknowledgment after a response is saved. Selecting
/// `less_comfortable` suppresses the celebratory check icon and uses the
/// approved safety copy instead.
class _FeedbackAcknowledged extends StatelessWidget {
  const _FeedbackAcknowledged({required this.rating, required this.onDone});

  final FeedbackRating rating;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lessComfortable = rating.isLessComfortable;

    final icon = lessComfortable
        ? Icons.self_improvement
        : Icons.favorite_border;
    final iconColor = lessComfortable
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;
    final message = lessComfortable
        ? strings.feedbackLessComfortableMessage
        : strings.feedbackThanks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 48, color: iconColor),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            key: const Key('feedback_acknowledgement'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: lessComfortable
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('feedback_done'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onDone,
            child: Text(strings.feedbackDone),
          ),
        ),
      ],
    );
  }
}

class _FeedbackSaveError extends StatelessWidget {
  const _FeedbackSaveError({required this.onRetry, required this.onSkip});

  final Future<void> Function() onRetry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          strings.feedbackSaveError,
          key: const Key('feedback_save_error'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('feedback_retry'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onRetry,
          child: Text(strings.feedbackRetry),
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('feedback_skip'),
          onPressed: onSkip,
          child: Text(strings.feedbackSkip),
        ),
      ],
    );
  }
}

class _AbandonedState extends StatelessWidget {
  const _AbandonedState({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 56,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    strings.playerEndedTitle,
                    key: const Key('player_ended'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.playerEndedBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('player_done'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onDone,
                    child: Text(strings.playerDone),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveErrorState extends StatelessWidget {
  const _SaveErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 56,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    strings.playerSaveErrorTitle,
                    key: const Key('player_save_error'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.playerSaveErrorBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('player_save_error_retry'),
                  onPressed: onRetry,
                  child: Text(strings.playerRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FailedState extends StatelessWidget {
  const _FailedState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    strings.playerUnavailable,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('player_retry'),
                  onPressed: onRetry,
                  child: Text(strings.playerRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTimer(int remainingSeconds) {
  final minutes = remainingSeconds ~/ 60;
  final seconds = remainingSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
