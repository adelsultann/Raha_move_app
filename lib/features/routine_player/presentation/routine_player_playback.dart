part of 'routine_player_screen.dart';

class _PlayerContent extends ConsumerWidget {
  const _PlayerContent({
    required this.session,
    required this.controller,
    required this.showGamification,
  });

  final RoutinePlaybackSession session;
  final RoutinePlayerController controller;
  final bool showGamification;

  Future<void> _handleClose(BuildContext context) async {
    if (session.isTerminal) {
      controller.finish();
      if (context.mounted) context.pop();
      return;
    }
    controller.pause();
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
    final preparing = session.preparationSeconds > 0;
    final isPlaying = session.status == PlaybackStatus.playing;
    final isPaused = session.status == PlaybackStatus.paused;

    if (session.isCompleted) {
      return _CompletedState(
        session: session,
        onDone: () => _handleClose(context),
        showGamification: showGamification,
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
              LinearProgressIndicator(
                value:
                    session.totalCreditedSeconds / session.totalDurationSeconds,
                minHeight: 3,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: ValueKey('guidance_${step.stepId}'),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        step.name,
                        key: const Key('player_movement_name'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow,
                          child: SizedBox(
                            key: const Key('player_video'),
                            height: (MediaQuery.sizeOf(context).height * .28)
                                .clamp(140.0, 260.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                demonstration.build(
                                  context,
                                  deliveryReference:
                                      step.mediaDeliveryReference,
                                  playing: isPlaying && !preparing,
                                ),
                                if (preparing)
                                  ColoredBox(
                                    color: Theme.of(context).colorScheme.surface
                                        .withValues(alpha: .94),
                                    child: Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              strings.playerGetReady,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Semantics(
                                              liveRegion: true,
                                              child: Text(
                                                '${session.preparationSeconds}',
                                                key: const Key(
                                                  'player_countdown',
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (preparing) ...[
                        Text(
                          strings.playerPrepareHint,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (step.description?.isNotEmpty == true) ...[
                        Text(
                          step.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        strings.playerHowTo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (step.instructions.isEmpty)
                        Text(
                          step.shortCue?.isNotEmpty == true
                              ? step.shortCue!
                              : strings.playerDefaultCue,
                        )
                      else ...[
                        for (var i = 0; i < step.instructions.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: Text(
                                    '${i + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    step.instructions[i],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (step.shortCue?.isNotEmpty == true)
                          Text(
                            step.shortCue!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (preparing)
                      TextButton(
                        onPressed: controller.startNow,
                        child: Text(strings.playerStartNow),
                      ),
                    ExcludeSemantics(
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
                      onPrevious: preparing ? null : controller.previous,
                      onTogglePause: controller.togglePause,
                      onSkip: preparing ? null : controller.skip,
                      onFinish: preparing ? null : controller.next,
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
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 0),
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

String _formatTimer(int remainingSeconds) {
  final minutes = remainingSeconds ~/ 60;
  final seconds = remainingSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
