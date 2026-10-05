import 'package:flutter/material.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';

import 'movement_duration_controls.dart';
import 'exercise_preview_thumbnail.dart';

class RoutineMovementRow extends StatelessWidget {
  const RoutineMovementRow({
    super.key,
    required this.index,
    required this.movement,
    required this.fallback,
    required this.seconds,
    this.onChange,
  });
  final int index, seconds;
  final MovementPreviewEntry movement;
  final String fallback;
  final ValueChanged<int>? onChange;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = MovementDurationControls(
      index: index,
      seconds: seconds,
      onChange: onChange,
    );
    return Padding(
      key: Key('explore_movement_$index'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(14) > 20;
          return Row(
            children: [
              ExercisePreviewThumbnail(
                index: index,
                movement: movement,
                fallback: fallback,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movement.name, style: theme.textTheme.titleMedium),
                    if (compact)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: controls,
                      ),
                  ],
                ),
              ),
              if (!compact) controls,
            ],
          );
        },
      ),
    );
  }
}
