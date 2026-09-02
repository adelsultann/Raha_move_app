import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/gamification_providers.dart';
import '../domain/weekly_goal_progress.dart';

/// Calm, single reward/progress summary used after feedback is saved.
class CompletionGamificationSummary extends ConsumerWidget {
  const CompletionGamificationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyGoalProgressProvider);
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
        data: (value) => _ProgressDetails(progress: value),
      ),
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  const _ProgressDetails({required this.progress});
  final WeeklyGoalProgress progress;

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
      ],
    );
  }
}
