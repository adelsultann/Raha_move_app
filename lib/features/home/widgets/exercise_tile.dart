import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../home_providers.dart';
import 'exercise_artwork.dart';
import 'exercise_sheet.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({super.key, required this.exercise});
  final HomeExercise exercise;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 182,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          key: Key('exercise_${exercise.id}'),
          borderRadius: BorderRadius.circular(24),
          onTap: () => openExercise(context, exercise),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ExerciseArtwork(
                    area: exercise.area,
                    image: exercise.image,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Text(
                    exercise.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)
                      .recommendationSeconds(exercise.seconds),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
