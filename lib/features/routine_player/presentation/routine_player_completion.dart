part of 'routine_player_screen.dart';

class _CompletedState extends ConsumerStatefulWidget {
  const _CompletedState({
    required this.session,
    required this.onDone,
    required this.showGamification,
  });

  final RoutinePlaybackSession session;
  final VoidCallback onDone;
  final bool showGamification;

  @override
  ConsumerState<_CompletedState> createState() => _CompletedStateState();
}

class _CompletedStateState extends ConsumerState<_CompletedState> {
  var _feedbackSkipped = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final args = RoutineFeedbackArgs(
      sessionId: widget.session.sessionId,
      routineId: widget.session.routineId,
    );
    final feedbackState = ref.watch(routineFeedbackControllerProvider(args));
    final controller = ref.read(
      routineFeedbackControllerProvider(args).notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
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
                strings.feedbackActiveMinutes(
                  widget.session.verifiedActiveMinutes,
                ),
                key: const Key('feedback_active_minutes'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (_feedbackSkipped)
                _CompletionProgress(
                  sessionId: widget.session.sessionId,
                  onDone: widget.onDone,
                  showGamification: widget.showGamification,
                )
              else
                _FeedbackBody(
                  state: feedbackState,
                  onSelect: controller.submit,
                  onRetry: controller.retry,
                  onSkip: () => setState(() => _feedbackSkipped = true),
                  onDone: widget.onDone,
                  sessionId: widget.session.sessionId,
                  showGamification: widget.showGamification,
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
    required this.sessionId,
    required this.showGamification,
  });

  final RoutineFeedbackState state;
  final Future<void> Function(FeedbackRating rating) onSelect;
  final Future<void> Function() onRetry;
  final VoidCallback onSkip;
  final VoidCallback onDone;
  final String sessionId;
  final bool showGamification;

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
        sessionId: sessionId,
        onDone: onDone,
        showGamification: showGamification,
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
  const _FeedbackAcknowledged({
    required this.rating,
    required this.sessionId,
    required this.onDone,
    required this.showGamification,
  });

  final FeedbackRating rating;
  final String sessionId;
  final VoidCallback onDone;
  final bool showGamification;

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
        const SizedBox(height: 20),
        if (!lessComfortable && showGamification)
          CompletionGamificationSummary(sessionId: sessionId),
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

/// Shown when feedback is optional so completion progress remains visible
/// without treating the skipped feedback path as celebratory.
class _CompletionProgress extends StatelessWidget {
  const _CompletionProgress({
    required this.sessionId,
    required this.onDone,
    required this.showGamification,
  });

  final String sessionId;
  final VoidCallback onDone;
  final bool showGamification;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showGamification) ...[
          CompletionGamificationSummary(sessionId: sessionId),
          const SizedBox(height: 24),
        ],
        FilledButton(
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
