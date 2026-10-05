import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/today/application/today_providers.dart';

import 'home_providers.dart';
import 'widgets/exercise_tile.dart';
import 'widgets/home_body_areas.dart';
import 'widgets/home_heading.dart';
import 'widgets/home_header.dart';
import 'widgets/home_routine_tile.dart';
import 'widgets/home_status.dart';

// Preserve the shared widgets available through the original screen import.
export 'widgets/exercise_artwork.dart' show ExerciseArtwork;
export 'widgets/exercise_sheet.dart' show openExercise;
export 'widgets/exercise_tile.dart' show ExerciseTile;
export 'widgets/home_body_areas.dart' show areaLabel;
export 'widgets/home_status.dart' show HomeError;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.recommendationsEnabled = true});

  final bool recommendationsEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final routines = ref.watch(
      exploreRoutinesProvider(filters: const ExploreFilters()),
    );
    final catalog = ref.watch(homeCatalogProvider);
    final resume = ref.watch(todayDashboardProvider).value?.resumableRoutine;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.5);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            HomeHeader(
              recommendationsEnabled: recommendationsEnabled,
              onBrowse: () => _browse(context),
              resume: resume,
            ),
            HomeHeading(
              s.homeRoutines,
              action: TextButton(
                onPressed: () => _browse(context),
                child: Text(s.homeViewAll),
              ),
            ),
            routines.when(
              loading: () => const HomeLoadingRow(),
              error: (_, _) => HomeError(
                onRetry: () => ref.invalidate(exploreRoutinesProvider),
              ),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(s.exploreEmptyBody),
                    )
                  : SizedBox(
                      height: 300 + 70 * (scale - 1),
                      child: ListView.separated(
                        key: const Key('home_routines'),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, i) => HomeRoutineTile(
                          card: items[i],
                          movements:
                              catalog.value?.sequences[items[i].routineId] ??
                              const [],
                        ),
                      ),
                    ),
            ),
            HomeHeading(s.homeBrowseAreas),
            HomeBodyAreas(
              scale: scale,
              onAreaSelected: (area) => _browse(context, area: area),
            ),
            HomeHeading(
              recommendationsEnabled ? s.homeRecommended : s.homeExercises,
            ),
            catalog.when(
              loading: () => const HomeLoadingRow(),
              error: (_, _) =>
                  HomeError(onRetry: () => ref.invalidate(homeCatalogProvider)),
              data: (data) => data.exercises.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(s.exploreEmptyBody),
                    )
                  : SizedBox(
                      height: 226 + 62 * (scale - 1),
                      child: ListView.separated(
                        key: const Key('home_exercises'),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: data.exercises.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, i) =>
                            ExerciseTile(exercise: data.exercises[i]),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _browse(BuildContext context, {String? area}) => Navigator.of(context)
      .push(
        MaterialPageRoute<void>(
          builder: (_) => ExploreScreen(initialBodyArea: area),
        ),
      );
}
