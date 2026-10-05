import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

class ExerciseInstructionSteps extends StatelessWidget {
  const ExerciseInstructionSteps({super.key, required this.instructions});

  final List<String> instructions;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (instructions.isEmpty) {
      return Text(strings.exercisePreviewNoInstructions);
    }
    return Column(
      children: [
        for (final (index, instruction) in instructions.indexed)
          Semantics(
            container: true,
            label: strings.checkInStepIndicator(index + 1, instructions.length),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 24,
                    child: ExcludeSemantics(
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.onSurfaceVariant,
                                width: 5,
                              ),
                            ),
                          ),
                          if (index < instructions.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index < instructions.length - 1 ? 24 : 0,
                      ),
                      child: Text(
                        instruction,
                        key: Key('exercise_instruction_$index'),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
