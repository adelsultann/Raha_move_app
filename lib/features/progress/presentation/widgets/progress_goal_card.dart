import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/progress_summary.dart';

class ProgressGoalCard extends StatelessWidget {
  const ProgressGoalCard({super.key, required this.summary});
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
