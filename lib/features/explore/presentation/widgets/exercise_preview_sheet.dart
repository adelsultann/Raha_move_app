import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';

import 'exercise_instruction_steps.dart';
import 'exercise_preview_video.dart';

Future<void> showExercisePreview(
  BuildContext context, {
  required MovementPreviewEntry movement,
  required String fallback,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  enableDrag: true,
  clipBehavior: Clip.antiAlias,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  sheetAnimationStyle: AnimationStyle(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300),
    reverseDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250),
  ),
  builder: (_) => ExercisePreviewSheet(movement: movement, fallback: fallback),
);

class ExercisePreviewSheet extends StatelessWidget {
  const ExercisePreviewSheet({
    super.key,
    required this.movement,
    required this.fallback,
  });

  final MovementPreviewEntry movement;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      key: const Key('exercise_preview_sheet'),
      initialChildSize: .88,
      minChildSize: .35,
      maxChildSize: .95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                ExercisePreviewVideo(
                  asset: movement.videoAsset,
                  poster: movement.thumbnailAsset ?? fallback,
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: IconButton.filledTonal(
                    key: const Key('exercise_preview_close'),
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      movement.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  if (movement.description?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(
                      movement.description!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 28),
                  Semantics(
                    header: true,
                    child: Text(
                      strings.exercisePreviewInstructions,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ExerciseInstructionSteps(instructions: movement.instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
