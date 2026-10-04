import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/app/theme/app_colors.dart' show AppColors;
import 'package:raha_move/core/assets/app_asset_catalog.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';
import 'package:raha_move/features/saved_routines/application/saved_routine_controller.dart';

import '../application/explore_providers.dart';
import '../domain/explore_models.dart';

class ExploreRoutineDetailsScreen extends ConsumerStatefulWidget {
  const ExploreRoutineDetailsScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<ExploreRoutineDetailsScreen> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<ExploreRoutineDetailsScreen> {
  final Map<String, int> durations = {};
  String get routineId => widget.routineId;
  @override
  Widget build(BuildContext context) {
    final details = ref.watch(exploreRoutineDetailsProvider(routineId));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          details.asData?.value?.presentation.name ?? '',
          key: const Key('explore_details_name'),
        ),
      ),
      bottomNavigationBar: details.asData?.value == null
          ? null
          : _StartBar(
              details: details.asData!.value!,
              durations: jsonEncode(durations),
            ),
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
            : _DetailsContent(
                details: value,
                durations: durations,
                onChange: (id, seconds) =>
                    setState(() => durations[id] = seconds),
              ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
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
                _SaveRoutineButton(routineId: routine.routineId),
              ],
              const SizedBox(height: 20),
              const Divider(),
              for (final (index, movement) in routine.movements.indexed) ...[
                _MovementRow(
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

class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.index,
    required this.movement,
    required this.fallback,
    required this.seconds,
    this.onChange,
  });
  final int index, seconds;
  final MovementPreviewEntry movement;
  final String fallback;
  final ValueChanged<int>? onChange;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          key: Key('exercise_decrease_$index'),
          tooltip: AppLocalizations.of(context).routineDecreaseTime,
          onPressed: onChange != null && seconds > 15
              ? () => onChange!((seconds - 15).clamp(15, 3600))
              : null,
          icon: const Icon(Icons.remove, size: 18),
           style: IconButton.styleFrom(
            
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
            key: Key('exercise_duration_$index'),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        IconButton.filledTonal(
          key: Key('exercise_increase_$index'),
          tooltip: AppLocalizations.of(context).routineIncreaseTime,
          onPressed: onChange != null && seconds < 3600
              ? () => onChange!((seconds + 15).clamp(15, 3600))
              : null,
          icon: const Icon(Icons.add, size: 18),
          style: IconButton.styleFrom(
            
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
    return Padding(
      key: Key('explore_movement_$index'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(14) > 20;
          return Row(
            children: [
              ClipOval(
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Image.asset(
                    movement.thumbnailAsset ?? fallback,
                    key: Key('exercise_thumbnail_$index'),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => Image.asset(
                      fallback,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movement.name, style: theme.textTheme.titleMedium),
                    if (compact)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: controls,
                      ),
                  ],
                ),
              ),
              if (!compact) controls,
            ],
          );
        },
      ),
    );
  }
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.details, required this.durations});
  final String durations;
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
              durations: durations,
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

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.routineId,
    required this.eligibility,
    required this.durations,
  });
  final String durations;
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
                  durations: durations,
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
