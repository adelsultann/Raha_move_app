import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
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

class _DetailsContent extends ConsumerWidget {
  const _DetailsContent({required this.details});
  final ExploreRoutineDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final routine = details.presentation;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    routine.name,
                    key: const Key('explore_details_name'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  routine.summary,
                  key: const Key('explore_details_purpose'),
                ),
                const SizedBox(height: 20),
                _Metadata(
                  routine: routine,
                  equipmentLabels: details.equipmentLabels,
                ),
                const SizedBox(height: 20),
                if (details.eligibility is RoutineStartAllowed)
                  _SaveRoutineButton(routineId: routine.routineId),
                const SizedBox(height: 20),
                Text(
                  strings.exploreMovementPreview,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final (index, movement) in routine.movements.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text('${index + 1}'),
                    title: Text(movement.name),
                    trailing: Text(
                      strings.recommendationSeconds(movement.durationSeconds),
                    ),
                  ),
                const SizedBox(height: 24),
                _StartButton(
                  routineId: routine.routineId,
                  eligibility: details.eligibility,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
        _DetailChip(
          strings.exploreDuration,
          strings.recommendationDurationMinutes(
            (routine.estimatedDurationSeconds / 60).ceil(),
          ),
        ),
        _DetailChip(
          strings.exploreDifficulty,
          _detailsDifficultyLabel(strings, routine.difficulty),
        ),
        _DetailChip(
          strings.explorePosition,
          routine.positions
              .map((key) => _detailsPositionLabel(strings, key))
              .join(', '),
        ),
        _DetailChip(
          strings.exploreEquipment,
          equipment,
          key: const Key('explore_details_equipment'),
        ),
        _DetailChip(
          strings.exploreExerciseCount,
          strings.recommendationMovementsCount(routine.movementCount),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip(this.label, this.value, {super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: Chip(label: Text('$label: $value')),
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
