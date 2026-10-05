import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import '../../domain/progress_summary.dart';

/// Keeps history dates in the active locale without exposing an ISO database
/// representation to the user.
String formatProgressHistoryDate(BuildContext context, MovementDate day) =>
    MaterialLocalizations.of(context)
        .formatMediumDate(DateTime.utc(day.year, day.month, day.day));

class ProgressHistoryTile extends StatelessWidget {
  const ProgressHistoryTile(this.item, {super.key});
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
