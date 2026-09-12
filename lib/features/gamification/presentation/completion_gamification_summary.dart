import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/gamification_providers.dart';
import '../domain/weekly_goal_progress.dart';
import '../domain/streak_progress.dart';

/// Calm, single reward/progress summary used after feedback is saved.
class CompletionGamificationSummary extends ConsumerWidget {
  const CompletionGamificationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyGoalProgressProvider);
    final streak = ref.watch(streakProgressProvider);
    final strings = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: strings.gamificationSummarySemantics,
      child: progress.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.gamificationProgressUnavailable,
              key: const Key('gamification_summary_error'),
              textAlign: TextAlign.center,
            ),
            TextButton(
              key: const Key('gamification_summary_retry'),
              onPressed: () => ref.invalidate(weeklyGoalProgressProvider),
              child: Text(strings.retry),
            ),
          ],
        ),
        data: (value) => _ProgressDetails(progress: value, streak: streak),
      ),
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  const _ProgressDetails({required this.progress, required this.streak});
  final WeeklyGoalProgress progress;
  final AsyncValue<StreakProgress> streak;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pending =
        progress.pendingPointAwards * GamificationRules.completionPoints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.gamificationWeeklyGoalProgress(
            progress.movementDays,
            progress.goalDays,
          ),
          key: const Key('gamification_weekly_goal'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        if (progress.confirmedPoints != null) ...[
          const SizedBox(height: 8),
          Text(
            strings.gamificationPointsConfirmed(progress.confirmedPoints!),
            key: const Key('gamification_confirmed_points'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (pending > 0) ...[
          const SizedBox(height: 8),
          Text(
            strings.gamificationPointsPending(pending),
            key: const Key('gamification_pending_points'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        streak.when(
          data: (value) {
            if (value.currentDays > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  strings.gamificationStreak(value.currentDays),
                  key: const Key('gamification_streak'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            if (value.longestDays > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  strings.gamificationStreakRestart,
                  key: const Key('gamification_streak_restart'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
