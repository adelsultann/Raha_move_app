import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';

import '../home_providers.dart';
import 'exercise_artwork.dart';

class HomeRoutineTile extends StatelessWidget {
  const HomeRoutineTile({
    super.key,
    required this.card,
    required this.movements,
  });
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
