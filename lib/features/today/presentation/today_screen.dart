import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import '../application/today_providers.dart';
import '../domain/today_repository.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onStartCheckIn,
    required this.onResume,
    required this.onRepeat,
  });

  final VoidCallback onStartCheckIn;
  final void Function(String routineId, String sessionId) onResume;
  final void Function(String routineId) onRepeat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(todayDashboardProvider);
    return Scaffold(
      body: SafeArea(
        child: dashboard.when(
          loading: () => const Center(
            child: CircularProgressIndicator(key: Key('today_loading')),
          ),
          error: (_, _) => _ErrorState(
            onRetry: () => ref.invalidate(todayDashboardProvider),
          ),
          data: (value) => _Content(
            dashboard: value,
            onStartCheckIn: onStartCheckIn,
            onResume: onResume,
            onRepeat: onRepeat,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.dashboard,
    required this.onStartCheckIn,
    required this.onResume,
    required this.onRepeat,
  });

  final TodayDashboard dashboard;
  final VoidCallback onStartCheckIn;
  final void Function(String routineId, String sessionId) onResume;
  final void Function(String routineId) onRepeat;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasMovementThisWeek = dashboard.weeklyGoal.movementDays > 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              strings.todayGreeting,
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 12),
          Text(strings.todayCheckInPrompt, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('start_check_in'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onStartCheckIn,
            icon: const Icon(Icons.arrow_forward),
            label: Text(strings.checkInStartTitle),
          ),
          const SizedBox(height: 24),
          _WeeklyGoalCard(progress: dashboard.weeklyGoal),
          const SizedBox(height: 20),
          if (dashboard.resumableRoutine case final routine?)
            _ResumeCard(
              routine: routine,
              onResume: () => onResume(routine.routineId, routine.sessionId),
            )
          else if (dashboard.latestCompletedRoutine case final routine?)
            _RecentRoutineCard(
              routine: routine,
              onRepeat: () => onRepeat(routine.routineId),
            )
          else
            _NewUserCard(),
          const SizedBox(height: 20),
          _BenefitCard(hasMovementThisWeek: hasMovementThisWeek),
        ],
      ),
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.progress});
  final WeeklyGoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = progress.boundedMovementDays / progress.goalDays;
    final status = progress.isAuthoritative
        ? strings.todayProgressSynced
        : strings.todayProgressLocal;
    final pending = progress.hasPendingConfirmation
        ? strings.gamificationPointsPending(
            progress.pendingPointAwards * GamificationRules.completionPoints,
          )
        : null;
    final semanticLabel = [
      strings.gamificationWeeklyGoalProgress(
        progress.movementDays,
        progress.goalDays,
      ),
      status,
      ?pending,
    ].join('. ');
    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(strings.todayWeeklyGoal, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: value),
              const SizedBox(height: 8),
              Text(
                strings.gamificationWeeklyGoalProgress(
                  progress.movementDays,
                  progress.goalDays,
                ),
              ),
              const SizedBox(height: 4),
              Text(status, style: theme.textTheme.bodySmall),
              if (progress.hasPendingConfirmation) ...[
                const SizedBox(height: 4),
                Text(pending!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.routine, required this.onResume});
  final TodayResumableRoutine routine;
  final VoidCallback onResume;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _ActionCard(
      title: strings.todayResumeTitle,
      body: routine.name == null
          ? strings.todayRoutineNameUnavailable
          : strings.todayResumeRoutine(routine.name!),
      buttonKey: const Key('today_resume'),
      buttonLabel: strings.playerResume,
      onPressed: onResume,
    );
  }
}

class _RecentRoutineCard extends StatelessWidget {
  const _RecentRoutineCard({required this.routine, required this.onRepeat});
  final TodayCompletedRoutine routine;
  final VoidCallback onRepeat;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _ActionCard(
      title: strings.todayRecentTitle,
      body: routine.name,
      buttonKey: const Key('today_repeat'),
      buttonLabel: strings.todayRepeat,
      onPressed: onRepeat,
    );
  }
}

class _NewUserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(strings.todayNewUser, key: const Key('today_new_user')),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.body,
    required this.buttonKey,
    required this.buttonLabel,
    required this.onPressed,
  });
  final String title;
  final String body;
  final Key buttonKey;
  final String buttonLabel;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(body),
            const SizedBox(height: 12),
            Semantics(
              label: buttonLabel,
              button: true,
              child: OutlinedButton(
                key: buttonKey,
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.hasMovementThisWeek});
  final bool hasMovementThisWeek;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.todayBenefitTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              hasMovementThisWeek
                  ? strings.todayBenefitWithMovement
                  : strings.todayBenefitStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                strings.todayUnavailable,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('today_retry'),
              onPressed: onRetry,
              child: Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
