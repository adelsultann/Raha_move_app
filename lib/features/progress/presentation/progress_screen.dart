import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import '../application/progress_providers.dart';
import '../domain/progress_summary.dart';

/// Keeps history dates in the active locale without exposing an ISO database
/// representation to the user.
String formatProgressHistoryDate(BuildContext context, MovementDate day) =>
    MaterialLocalizations.of(context)
        .formatMediumDate(DateTime.utc(day.year, day.month, day.day));

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  MovementDate? _weekStart;

  @override
  Widget build(BuildContext context) {
    final currentWeek = ref.watch(localCurrentProgressWeekProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).progressTitle)),
      body: currentWeek.when(
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('progress_loading')),
        ),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.invalidate(localCurrentProgressWeekProvider),
        ),
        data: (current) {
          final week = _weekStart ?? current;
          final summary = ref.watch(progressSummaryProvider(week));
          return summary.when(
            loading: () => const Center(
              child: CircularProgressIndicator(key: Key('progress_loading')),
            ),
            error: (_, _) => _ErrorState(
              onRetry: () => ref.invalidate(progressSummaryProvider(week)),
            ),
            data: (value) => _Summary(
              summary: value,
              isCurrent: week == current,
              onPrevious: () => setState(() => _weekStart = week.addDays(-7)),
              onNext: week == current
                  ? null
                  : () => setState(() => _weekStart = week.addDays(7)),
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
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
    final theme = Theme.of(context);
    final range = MaterialLocalizations.of(context).formatMediumDate(
      DateTime.utc(
        summary.weekStart.year,
        summary.weekStart.month,
        summary.weekStart.day,
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                label: strings.progressPreviousWeek,
                button: true,
                child: IconButton(
                  key: const Key('progress_previous_week'),
                  tooltip: strings.progressPreviousWeek,
                  onPressed: onPrevious,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    isCurrent
                        ? strings.progressThisWeek
                        : strings.progressWeekStarting(range),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              Semantics(
                label: strings.progressNextWeek,
                button: true,
                child: IconButton(
                  key: const Key('progress_next_week'),
                  tooltip: strings.progressNextWeek,
                  onPressed: onNext,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (summary.hasProvisionalProgress) _ProvisionalBanner(),
          if (summary.hasProvisionalProgress) const SizedBox(height: 12),
          if (summary.isEmpty)
            _EmptyState()
          else ...[
            _GoalCard(summary: summary),
            const SizedBox(height: 16),
            _Metrics(summary: summary),
            const SizedBox(height: 24),
            _Section(
              title: strings.progressFeedbackTrend,
              child: _Feedback(summary.feedback),
            ),
            const SizedBox(height: 24),
            _Section(
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
            _Section(
              title: strings.progressRecentHistory,
              child: Column(
                children: summary.recentHistory.map(_HistoryTile.new).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.summary});
  final ProgressSummary summary;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: s.progressGoalSemantics(
        summary.movementDays,
        summary.weeklyGoalDays,
      ),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.progressWeeklyGoal,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (summary.movementDays / summary.weeklyGoalDays).clamp(
                  0,
                  1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.progressMovementDays(
                  summary.movementDays,
                  summary.weeklyGoalDays,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.summary});
  final ProgressSummary summary;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _Metric(
            label: s.progressMovementDaysLabel,
            value: '${summary.movementDays}',
          ),
        ),
        Expanded(
          child: _Metric(
            label: s.progressVerifiedMinutes,
            value: '${summary.verifiedActiveMinutes}',
          ),
        ),
        Expanded(
          child: _Metric(
            label: s.progressCompletedRoutines,
            value: '${summary.completedRoutines}',
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

class _Feedback extends StatelessWidget {
  const _Feedback(this.feedback);
  final FeedbackTrend feedback;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Text(
      feedback.total == 0
          ? s.progressNoFeedback
          : s.progressFeedbackSummary(feedback.feltBetter, feedback.total),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.item);
  final CompletedRoutineHistory item;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final name = item.routineName ?? s.progressRoutineUnavailable;
    final date = formatProgressHistoryDate(context, item.completedDay);
    return Semantics(
      container: true,
      label: s.progressHistorySemantics(name, item.verifiedActiveMinutes),
      child: ListTile(
        key: Key('progress_history_${item.sessionId}'),
        contentPadding: EdgeInsets.zero,
        title: Text(name),
        subtitle: Text(date),
        trailing: Text(s.progressMinutes(item.verifiedActiveMinutes)),
      ),
    );
  }
}

class _ProvisionalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined),
              const SizedBox(width: 8),
              Expanded(child: Text(s.progressLocalPending)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          const Icon(Icons.self_improvement_outlined, size: 48),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              s.progressEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(s.progressEmptyBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.progressError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('progress_retry'),
              onPressed: onRetry,
              child: Text(s.retry),
            ),
          ],
        ),
      ),
    );
  }
}
