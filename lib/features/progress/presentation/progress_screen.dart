import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import '../application/progress_providers.dart';
import 'widgets/progress_status.dart';
import 'widgets/progress_summary_view.dart';

export 'widgets/progress_history_tile.dart' show formatProgressHistoryDate;

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
        loading: () => const ProgressLoadingState(),
        error: (_, _) => ProgressErrorState(
          onRetry: () => ref.invalidate(localCurrentProgressWeekProvider),
        ),
        data: (current) {
          final week = _weekStart ?? current;
          final summary = ref.watch(progressSummaryProvider(week));
          return summary.when(
            loading: () => const ProgressLoadingState(),
            error: (_, _) => ProgressErrorState(
              onRetry: () => ref.invalidate(progressSummaryProvider(week)),
            ),
            data: (value) => ProgressSummaryView(
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
