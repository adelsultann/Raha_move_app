import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/core/assets/app_asset_catalog.dart';

import '../../domain/explore_models.dart';
import 'routine_movement_row.dart';
import 'save_routine_button.dart';

class RoutineDetailsContent extends StatelessWidget {
  const RoutineDetailsContent({
    super.key,
    required this.details,
    required this.durations,
    required this.onChange,
  });
  final Map<String, int> durations;
  final void Function(String, int) onChange;
  final ExploreRoutineDetails details;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final routine = details.presentation;
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                strings.recommendationDurationMinutes(
                  (routine.movements.fold<int>(
                            0,
                            (sum, m) =>
                                sum +
                                (durations[m.stepId] ?? m.durationSeconds),
                          ) /
                          60)
                      .ceil(),
                ),
                key: const Key('explore_details_duration'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                routine.summary,
                key: const Key('explore_details_purpose'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (details.eligibility is RoutineStartAllowed) ...[
                const SizedBox(height: 20),
                SaveRoutineButton(routineId: routine.routineId),
              ],
              const SizedBox(height: 20),
              const Divider(),
              for (final (index, movement) in routine.movements.indexed) ...[
                RoutineMovementRow(
                  index: index,
                  movement: movement,
                  fallback: AppAssetCatalog.routineArtwork(details.bodyAreas),
                  seconds:
                      durations[movement.stepId] ?? movement.durationSeconds,
                  onChange: movement.stepId == null
                      ? null
                      : (seconds) => onChange(movement.stepId!, seconds),
                ),
                if (index < routine.movements.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
