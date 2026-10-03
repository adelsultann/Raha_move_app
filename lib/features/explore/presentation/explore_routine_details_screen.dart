import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/core/assets/app_asset_catalog.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';
import 'package:raha_move/features/saved_routines/application/saved_routine_controller.dart';

import '../application/explore_providers.dart';
import '../domain/explore_models.dart';

class ExploreRoutineDetailsScreen extends ConsumerWidget {
  const ExploreRoutineDetailsScreen({super.key, required this.routineId});
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(exploreRoutineDetailsProvider(routineId));
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: details.asData?.value == null
          ? null
          : _StartBar(details: details.asData!.value!),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _DetailsUnavailable(
          onRetry: () =>
              ref.invalidate(exploreRoutineDetailsProvider(routineId)),
        ),
        data: (value) => value == null
            ? _DetailsUnavailable(
                onRetry: () =>
                    ref.invalidate(exploreRoutineDetailsProvider(routineId)),
              )
            : _DetailsContent(details: value),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.details});
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
              _RoutineHero(details: details),
              const SizedBox(height: 20),
              Text(
                routine.summary,
                key: const Key('explore_details_purpose'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _Metadata(
                routine: routine,
                equipmentLabels: details.equipmentLabels,
              ),
              if (details.eligibility is RoutineStartAllowed) ...[
                const SizedBox(height: 20),
                _SaveRoutineButton(routineId: routine.routineId),
              ],
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  strings.exploreMovementPreview,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.recommendationMovementsCount(routine.movementCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final (index, movement) in routine.movements.indexed) ...[
                _MovementRow(index: index, movement: movement),
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

class _RoutineHero extends StatelessWidget {
  const _RoutineHero({required this.details});
  final ExploreRoutineDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routine = details.presentation;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                AppAssetCatalog.routineArtwork(details.bodyAreas),
                key: const Key('explore_details_artwork'),
                height: 200,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 200,
                  child: Icon(Icons.self_improvement, size: 80),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    routine.name,
                    key: const Key('explore_details_name'),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)
                            .recommendationDurationMinutes(
                              (routine.estimatedDurationSeconds / 60).ceil(),
                            ),
                        key: const Key('explore_details_duration'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.index, required this.movement});
  final int index;
  final MovementPreviewEntry movement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Container(
        key: Key('explore_movement_$index'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                MaterialLocalizations.of(context).formatDecimal(index + 1),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movement.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)
                        .recommendationSeconds(movement.durationSeconds),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.details});
  final ExploreRoutineDetails details;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      top: false,
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: MediaQuery.sizeOf(context).height * .4,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: _StartButton(
              routineId: details.presentation.routineId,
              eligibility: details.eligibility,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SaveRoutineButton extends ConsumerWidget {
  const _SaveRoutineButton({required this.routineId});
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final saved = ref.watch(savedRoutineControllerProvider(routineId));
    final isSaved = saved.value ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          enabled: !saved.isLoading,
          child: OutlinedButton.icon(
            key: const Key('explore_details_save'),
            onPressed: saved.isLoading
                ? null
                : () => ref
                      .read(savedRoutineControllerProvider(routineId).notifier)
                      .toggle(),
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
            label: Text(
              isSaved ? strings.savedRoutineUnsave : strings.savedRoutineSave,
            ),
          ),
        ),
        if (saved.hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8),
            child: Text(
              strings.savedRoutineChangeError,
              key: const Key('explore_details_save_error'),
            ),
          ),
      ],
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.routine, required this.equipmentLabels});
  final RoutinePresentation routine;
  final Map<String, String> equipmentLabels;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final equipment = routine.equipment.isEmpty
        ? strings.recommendationNoEquipment
        : routine.equipment
              .map((key) => equipmentLabels[key] ?? key)
              .join(', ');
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _DetailInfo(
          strings.exploreDifficulty,
          _detailsDifficultyLabel(strings, routine.difficulty),
        ),
        _DetailInfo(
          strings.explorePosition,
          routine.positions
              .map((key) => _detailsPositionLabel(strings, key))
              .join(', '),
        ),
        _DetailInfo(
          strings.exploreEquipment,
          equipment,
          key: const Key('explore_details_equipment'),
        ),
      ],
    );
  }
}

class _DetailInfo extends StatelessWidget {
  const _DetailInfo(this.label, this.value, {super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.routineId, required this.eligibility});
  final String routineId;
  final RoutineStartEligibility eligibility;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final allowed = eligibility is RoutineStartAllowed;
    final message = switch (eligibility) {
      RoutineStartBlocked(:final reason) => switch (reason) {
        RoutineStartBlock.retired => strings.exploreStartRetired,
        RoutineStartBlock.incompatible => strings.exploreStartIncompatible,
        RoutineStartBlock.unavailable => strings.exploreStartUnavailable,
        RoutineStartBlock.unauthorized => strings.exploreStartUnauthorized,
      },
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: Text(message, key: const Key('explore_start_blocked')),
          ),
        FilledButton(
          key: const Key('explore_start'),
          onPressed: allowed
              ? () => RoutinePlayerRoute(
                  routineId: routineId,
                  source: 'explore',
                ).push(context)
              : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: Text(strings.recommendationStart),
        ),
      ],
    );
  }
}

class _DetailsUnavailable extends StatelessWidget {
  const _DetailsUnavailable({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.exploreDetailsUnavailable),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(strings.retry)),
        ],
      ),
    );
  }
}

String _detailsPositionLabel(AppLocalizations strings, String key) =>
    switch (key) {
      'seated' => strings.checkInPositionSeated,
      'standing' => strings.checkInPositionStanding,
      _ => strings.checkInPositionFloor,
    };

String _detailsDifficultyLabel(
  AppLocalizations strings,
  DifficultyLevel difficulty,
) => switch (difficulty) {
  DifficultyLevel.beginner => strings.recommendationDifficultyBeginner,
  DifficultyLevel.intermediate => strings.recommendationDifficultyIntermediate,
  DifficultyLevel.advanced => strings.recommendationDifficultyAdvanced,
};
