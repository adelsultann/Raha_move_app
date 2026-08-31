import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../../domain/routine_presentation.dart';

/// Shows a concise, ordered movement preview as a modal bottom sheet. The user
/// can review movements without being forced to inspect them before starting.
Future<void> showMovementPreviewSheet(
  BuildContext context,
  List<MovementPreviewEntry> movements,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _MovementPreviewSheet(movements: movements),
  );
}

class _MovementPreviewSheet extends StatelessWidget {
  const _MovementPreviewSheet({required this.movements});

  final List<MovementPreviewEntry> movements;

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
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: movements.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movement = movements[index];
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
          ],
        ),
      ),
    );
  }
}
