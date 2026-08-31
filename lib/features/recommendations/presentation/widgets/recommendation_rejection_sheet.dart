import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/recommendation_rejection.dart';

/// Shows the five rejection reasons as a modal bottom sheet and invokes
/// [onSelected] with the chosen reason.
Future<void> showRejectionReasonSheet(
  BuildContext context,
  ValueChanged<RecommendationRejectionReason> onSelected,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _RejectionReasonSheet(onSelected: onSelected),
  );
}

class _RejectionReasonSheet extends StatelessWidget {
  const _RejectionReasonSheet({required this.onSelected});

  final ValueChanged<RecommendationRejectionReason> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final options = <(RecommendationRejectionReason, String, String)>[
      (
        RecommendationRejectionReason.tooEasy,
        strings.recommendationRejectTooEasy,
        'too_easy',
      ),
      (
        RecommendationRejectionReason.tooDifficult,
        strings.recommendationRejectTooDifficult,
        'too_difficult',
      ),
      (
        RecommendationRejectionReason.position,
        strings.recommendationRejectPosition,
        'position',
      ),
      (
        RecommendationRejectionReason.discomfort,
        strings.recommendationRejectDiscomfort,
        'discomfort',
      ),
      (
        RecommendationRejectionReason.other,
        strings.recommendationRejectOther,
        'other',
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.recommendationRejectTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final (reason, label, key) in options)
              ListTile(
                key: Key('recommendation_reject_$key'),
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                onTap: () {
                  Navigator.of(context).pop();
                  onSelected(reason);
                },
              ),
          ],
        ),
      ),
    );
  }
}
