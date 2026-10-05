import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/progress_summary.dart';

class ProgressMetrics extends StatelessWidget {
  const ProgressMetrics({super.key, required this.summary});
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
            label: summary.hasProvisionalProgress
                ? s.progressLocalActiveMinutes
                : s.progressVerifiedMinutes,
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
