import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';

import 'exercise_preview_sheet.dart';

class ExercisePreviewThumbnail extends StatelessWidget {
  const ExercisePreviewThumbnail({
    super.key,
    required this.index,
    required this.movement,
    required this.fallback,
  });

  final int index;
  final MovementPreviewEntry movement;
  final String fallback;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: AppLocalizations.of(context).exercisePreviewOpen(movement.name),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('exercise_preview_open_$index'),
        customBorder: const CircleBorder(),
        onTap: () => showExercisePreview(
          context,
          movement: movement,
          fallback: fallback,
        ),
        child: Image.asset(
          movement.thumbnailAsset ?? fallback,
          key: Key('exercise_thumbnail_$index'),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => Image.asset(
            fallback,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    ),
  );
}
