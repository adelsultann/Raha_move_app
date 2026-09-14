import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/saved_routines/presentation/saved_routines_screen.dart';

import 'home_providers.dart';
import 'home_screen.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.navigationLibrary),
          bottom: TabBar(
            tabs: [
              Tab(text: s.libraryRoutines),
              Tab(text: s.libraryExercises),
            ],
          ),
        ),
        body: const TabBarView(
          children: [SavedRoutinesScreen(embedded: true), _SavedExercises()],
        ),
      ),
    );
  }
}

class _SavedExercises extends ConsumerWidget {
  const _SavedExercises();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final ids = ref.watch(savedExerciseIdsProvider);
    final catalog = ref.watch(homeCatalogProvider);
    if (ids.hasError || catalog.hasError) {
      return HomeError(
        onRetry: () {
          ref.invalidate(savedExerciseIdsProvider);
          ref.invalidate(homeCatalogProvider);
        },
      );
    }
    if (ids.isLoading || catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final exercises = {for (final e in catalog.requireValue.exercises) e.id: e};
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          s.libraryLocalNotice,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        if (ids.requireValue.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                const Icon(Icons.bookmarks_outlined, size: 48),
                const SizedBox(height: 16),
                Text(s.libraryExerciseEmpty, textAlign: TextAlign.center),
              ],
            ),
          ),
        for (final id in ids.requireValue)
          Card(
            child: ListTile(
              key: Key('saved_exercise_$id'),
              leading: ExerciseArtwork(
                area: exercises[id]?.area ?? 'full_body',
                image: exercises[id]?.image,
                size: 54,
              ),
              title: Text(
                exercises[id]?.name ?? s.savedRoutinesUnavailableBody,
              ),
              subtitle: exercises[id] == null
                  ? null
                  : Text(s.recommendationSeconds(exercises[id]!.seconds)),
              onTap: exercises[id] == null
                  ? null
                  : () => openExercise(context, exercises[id]!),
              trailing: IconButton(
                tooltip: s.exerciseUnsave,
                icon: const Icon(Icons.bookmark_remove_outlined),
                onPressed: () async {
                  try {
                    await setExerciseSaved(ref, id, false);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.savedRoutinesError)),
                      );
                    }
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}
