import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/presentation/achievement_progress_section.dart';

import '../../domain/progress_summary.dart';
import 'progress_week_navigation.dart';
import 'progress_goal_card.dart';
import 'progress_metrics.dart';
import 'progress_section.dart';
import 'progress_feedback.dart';
import 'progress_history_tile.dart';
import 'progress_status.dart';

class ProgressSummaryView extends StatelessWidget {
  const ProgressSummaryView({
    super.key,
    required this.summary,
    required this.isCurrent,
    required this.onPrevious,
    required this.onNext,
  });
  final ProgressSummary summary;
  final bool isCurrent;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressWeekNavigation(
            weekStart: summary.weekStart,
            isCurrent: isCurrent,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
          const SizedBox(height: 16),
          if (summary.hasProvisionalProgress) const ProgressProvisionalBanner(),
          if (summary.hasProvisionalProgress) const SizedBox(height: 12),
          if (summary.isEmpty)
            const ProgressEmptyState()
          else ...[
            ProgressGoalCard(summary: summary),
            const SizedBox(height: 16),
            ProgressMetrics(summary: summary),
            const SizedBox(height: 24),
            ProgressSection(
              title: strings.progressFeedbackTrend,
              child: ProgressFeedback(summary.feedback),
            ),
            const SizedBox(height: 24),
            ProgressSection(
              title: strings.progressBodyAreas,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: summary.bodyAreas
                    .map((area) => Chip(label: Text(area.label)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            ProgressSection(
              title: strings.progressRecentHistory,
              child: Column(
                children: summary.recentHistory
                    .map(ProgressHistoryTile.new)
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const AchievementProgressSection(),
        ],
      ),
    );
  }
}
