import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/today/application/today_providers.dart';

import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.navigationHome.toUpperCase(),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.homeHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.homeSubtitle,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('start_check_in'),
                    onPressed: () => const CheckInRoute().push(context),
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(s.checkInStartTitle),
                  ),
                  if (resume != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.play_circle_outline,
                          color: colors.primary,
                        ),
                        title: Text(s.homeResume),
                        subtitle: Text(resume.name ?? s.navigationHome),
                        onTap: () => RoutinePlayerRoute(
                          routineId: resume.routineId,
                          sessionId: resume.sessionId,
                        ).push(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _Heading(
              s.homeRoutines,
              action: TextButton(
                onPressed: () => _browse(context),
                child: Text(s.homeViewAll),
              ),
            ),
            routines.when(
              loading: () => const _LoadingRow(),
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
                        itemBuilder: (context, i) => _RoutineTile(
                          card: items[i],
                          movements:
                              catalog.value?.sequences[items[i].routineId] ??
                              const [],
                        ),
                      ),
                    ),
            ),
            _Heading(s.homeBrowseAreas),
            SizedBox(
              height: 146 + 36 * (scale - 1),
              child: ListView.separated(
                key: const Key('home_areas'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: areaAssets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final area = areaAssets.keys.elementAt(index);
                  return SizedBox(
                    width: 112,
                    child: Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        key: Key('home_area_$area'),
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _browse(context, area: area),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ExerciseArtwork(area: area, size: 82),
                              const SizedBox(height: 10),
                              Flexible(
                                child: Text(
                                  areaLabel(s, area),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _Heading(s.homeRecommended),
            catalog.when(
              loading: () => const _LoadingRow(),
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

class _Heading extends StatelessWidget {
  const _Heading(this.title, {this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 16, 16),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        ?action,
      ],
    ),
  );
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.card, required this.movements});
  final ExploreRoutineCard card;
  final List<HomeExercise> movements;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final width = math.min(294.0, MediaQuery.sizeOf(context).width - 64);
    return SizedBox(
      width: width,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('home_routine_${card.routineId}'),
          onTap: () =>
              ExploreRoutineDetailsRoute(routineId: card.routineId)
                  .push(context),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.recommendationDurationMinutes(
                          (card.durationSeconds / 60).ceil(),
                        ),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  card.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 132,
                      width: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (movements.isEmpty)
                            const ExerciseArtwork(area: 'full_body', size: 110),
                          for (
                            var i = 0;
                            i < math.min(movements.length, 3);
                            i++
                          )
                            PositionedDirectional(
                              start: movements.length == 1 ? 62 : i * 58.0,
                              top: i.isOdd ? 30 : 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: ExerciseArtwork(
                                  area: movements[i].area,
                                  image: movements[i].image,
                                  size: 94,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.recommendationMovementsCount(card.movementCount),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExerciseArtwork extends StatelessWidget {
  const ExerciseArtwork({
    super.key,
    required this.area,
    this.image,
    this.size = 96,
  });
  final String area;
  final String? image;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        image ?? areaAsset(area),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => Image.asset(
          areaAsset(area),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    ),
  );
}

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

class HomeError extends StatelessWidget {
  const HomeError({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(AppLocalizations.of(context).exploreError),
        TextButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 150,
    child: Center(child: CircularProgressIndicator()),
  );
}

String areaLabel(AppLocalizations s, String area) => switch (area) {
  'neck' => s.checkInAreaNeck,
  'shoulders' => s.checkInAreaShoulders,
  'upper_back' => s.checkInAreaUpperBack,
  'lower_back' => s.checkInAreaLowerBack,
  'hips' => s.checkInAreaHips,
  'knees' => s.checkInAreaKnees,
  _ => s.checkInAreaFullBody,
};
