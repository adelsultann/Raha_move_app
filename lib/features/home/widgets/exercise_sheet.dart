import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';

import '../home_providers.dart';
import 'exercise_artwork.dart';

void openExercise(BuildContext context, HomeExercise exercise) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ExerciseSheet(exercise: exercise),
    );

class _ExerciseSheet extends ConsumerStatefulWidget {
  const _ExerciseSheet({required this.exercise});
  final HomeExercise exercise;
  @override
  ConsumerState<_ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends ConsumerState<_ExerciseSheet> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final saved = ref.watch(savedExerciseIdsProvider);
    final isSaved = saved.value?.contains(widget.exercise.id) ?? false;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExerciseArtwork(
              area: widget.exercise.area,
              image: widget.exercise.image,
              size: 156,
            ),
            const SizedBox(height: 20),
            Text(
              widget.exercise.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(s.recommendationSeconds(widget.exercise.seconds)),
            const SizedBox(height: 16),
            Text(widget.exercise.description, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: busy || saved.isLoading || saved.hasError
                  ? null
                  : () async {
                      setState(() => busy = true);
                      try {
                        await setExerciseSaved(
                          ref,
                          widget.exercise.id,
                          !isSaved,
                        );
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.savedRoutinesError)),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
              label: Text(isSaved ? s.exerciseUnsave : s.exerciseSave),
            ),
            if (saved.hasError)
              TextButton(
                onPressed: () => ref.invalidate(savedExerciseIdsProvider),
                child: Text(s.retry),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ExploreRoutineDetailsRoute(routineId: widget.exercise.routineId)
                    .push(context);
              },
              child: Text(s.exerciseOpenRoutine),
            ),
          ],
        ),
      ),
    );
  }
}
