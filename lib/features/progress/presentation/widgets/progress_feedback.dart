import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/progress_summary.dart';

class ProgressFeedback extends StatelessWidget {
  const ProgressFeedback(this.feedback, {super.key});
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
