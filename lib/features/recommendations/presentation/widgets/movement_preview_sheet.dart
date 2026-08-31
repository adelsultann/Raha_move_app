import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/routine_presentation.dart';

/// Shows the ordered movement preview for a recommended routine as a modal
/// bottom sheet (RAHA-050).
///
/// The user can review the ordered movements, the total duration, and a concise
/// safety reminder, then either start directly or dismiss the sheet and return
/// to the recommendation without losing the check-in. It never offers movement
/// replacement, because per-step replacement is not part of the MVP.
Future<void> showMovementPreviewSheet(
  BuildContext context, {
  required RoutinePresentation presentation,
  required VoidCallback onStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) =>
        _MovementPreviewSheet(presentation: presentation, onStart: onStart),
  );
}

class _MovementPreviewSheet extends StatelessWidget {
  const _MovementPreviewSheet({
    required this.presentation,
    required this.onStart,
  });

  final RoutinePresentation presentation;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.recommendationMovements,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${strings.recommendationTotalTime} · '
              '${_totalLabel(strings, presentation.totalDurationSeconds)}',
              key: const Key('preview_total_duration'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: presentation.movements.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movement = presentation.movements[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          movement.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        strings.recommendationSeconds(movement.durationSeconds),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.recommendationSafetyReminder,
                      key: const Key('preview_safety_reminder'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('preview_start'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onStart();
                },
                child: Text(strings.recommendationStart),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _totalLabel(AppLocalizations strings, int seconds) {
    if (seconds < 60 || seconds % 60 != 0) {
      return strings.recommendationSeconds(seconds);
    }
    return strings.recommendationDurationMinutes(seconds ~/ 60);
  }
}
