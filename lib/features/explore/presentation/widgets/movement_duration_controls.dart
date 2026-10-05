import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

class MovementDurationControls extends StatelessWidget {
  const MovementDurationControls({
    super.key,
    required this.index,
    required this.seconds,
    this.onChange,
  });

  final int index;
  final int seconds;
  final ValueChanged<int>? onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          key: Key('exercise_decrease_$index'),
          tooltip: AppLocalizations.of(context).routineDecreaseTime,
          onPressed: onChange != null && seconds > 15
              ? () => onChange!((seconds - 15).clamp(15, 3600))
              : null,
          icon: const Icon(Icons.remove, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
            key: Key('exercise_duration_$index'),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        IconButton.filledTonal(
          key: Key('exercise_increase_$index'),
          tooltip: AppLocalizations.of(context).routineIncreaseTime,
          onPressed: onChange != null && seconds < 3600
              ? () => onChange!((seconds + 15).clamp(15, 3600))
              : null,
          icon: const Icon(Icons.add, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
