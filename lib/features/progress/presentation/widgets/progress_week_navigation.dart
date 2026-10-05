import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

class ProgressWeekNavigation extends StatelessWidget {
  const ProgressWeekNavigation({
    super.key,
    required this.weekStart,
    required this.isCurrent,
    required this.onPrevious,
    required this.onNext,
  });

  final MovementDate weekStart;
  final bool isCurrent;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final range = MaterialLocalizations.of(context).formatMediumDate(
      DateTime.utc(weekStart.year, weekStart.month, weekStart.day),
    );
    return Row(
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
    );
  }
}
