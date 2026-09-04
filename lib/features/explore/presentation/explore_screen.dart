import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';

import '../application/explore_providers.dart';
import '../domain/explore_models.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  ExploreFilters _filters = const ExploreFilters();
  String? _context;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final routines = ref.watch(
      exploreRoutinesProvider(context: _context, filters: _filters),
    );
    final categories = ref.watch(exploreCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.exploreTitle)),
      body: SafeArea(
        child: Column(
          children: [
            categories.when(
              loading: () => const SizedBox(height: 48),
              error: (_, _) => _CategoryError(
                onRetry: () => ref.invalidate(exploreCategoriesProvider),
              ),
              data: (items) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      key: const Key('explore_category_all'),
                      label: Text(strings.exploreAllCategories),
                      selected: _context == null,
                      onSelected: (_) => setState(() => _context = null),
                    ),
                    for (final item in items) ...[
                      const SizedBox(width: 8),
                      ChoiceChip(
                        key: Key('explore_category_${item.key}'),
                        label: Text(item.label),
                        selected: _context == item.key,
                        onSelected: (_) => setState(() => _context = item.key),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _FilterBar(
              filters: _filters,
              onChanged: (filters) => setState(() => _filters = filters),
            ),
            Expanded(
              child: routines.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _ExploreError(
                  onRetry: () => ref.invalidate(
                    exploreRoutinesProvider(
                      context: _context,
                      filters: _filters,
                    ),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? _ExploreEmpty(
                        hasFilters: !_filters.isEmpty || _context != null,
                        onClear: () => setState(() {
                          _context = null;
                          _filters = const ExploreFilters();
                        }),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _RoutineCard(
                          card: items[index],
                          onTap: () => ExploreRoutineDetailsRoute(
                            routineId: items[index].routineId,
                          ).push(context),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filters, required this.onChanged});
  final ExploreFilters filters;
  final ValueChanged<ExploreFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Row(
        children: [
          _MultiFilter<int>(
            key: const Key('explore_duration_filter'),
            label: strings.exploreDuration,
            values: const [3, 5, 10, 15],
            selected: filters.durationsMinutes,
            itemLabel: strings.exploreMinutes,
            onChanged: (value) =>
                onChanged(filters.copyWith(durationsMinutes: value)),
          ),
          _MultiFilter<String>(
            key: const Key('explore_body_area_filter'),
            label: strings.exploreBodyArea,
            values: const [
              'neck',
              'shoulders',
              'upper_back',
              'lower_back',
              'hips',
              'knees',
              'full_body',
            ],
            selected: filters.bodyAreas,
            itemLabel: (value) => _bodyLabel(strings, value),
            onChanged: (value) => onChanged(filters.copyWith(bodyAreas: value)),
          ),
          _MultiFilter<String>(
            key: const Key('explore_position_filter'),
            label: strings.explorePosition,
            values: const ['seated', 'standing', 'floor'],
            selected: filters.positions,
            itemLabel: (value) => _positionLabel(strings, value),
            onChanged: (value) => onChanged(filters.copyWith(positions: value)),
          ),
          _MultiFilter<DifficultyLevel>(
            key: const Key('explore_difficulty_filter'),
            label: strings.exploreDifficulty,
            values: DifficultyLevel.values,
            selected: filters.difficulties,
            itemLabel: (value) => _difficultyLabel(strings, value),
            onChanged: (value) =>
                onChanged(filters.copyWith(difficulties: value)),
          ),
          _MultiFilter<String>(
            key: const Key('explore_equipment_filter'),
            label: strings.exploreEquipment,
            values: const ['body_weight'],
            selected: filters.equipment,
            itemLabel: (_) => strings.recommendationNoEquipment,
            onChanged: (value) => onChanged(filters.copyWith(equipment: value)),
          ),
          if (!filters.isEmpty)
            TextButton(
              key: const Key('explore_clear_filters'),
              onPressed: () => onChanged(const ExploreFilters()),
              child: Text(strings.exploreClear),
            ),
        ],
      ),
    );
  }
}

class _MultiFilter<T> extends StatelessWidget {
  const _MultiFilter({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.itemLabel,
    required this.onChanged,
  });
  final String label;
  final List<T> values;
  final Set<T> selected;
  final String Function(T) itemLabel;
  final ValueChanged<Set<T>> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: FilterChip(
      label: Text(selected.isEmpty ? label : '$label (${selected.length})'),
      selected: selected.isNotEmpty,
      onSelected: (_) async {
        final result = await showModalBottomSheet<Set<T>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: FractionallySizedBox(
              heightFactor: .9,
              child: _FilterSheet(
                values: values,
                selected: selected,
                itemLabel: itemLabel,
              ),
            ),
          ),
        );
        if (result != null) onChanged(result);
      },
    ),
  );
}

class _FilterSheet<T> extends StatefulWidget {
  const _FilterSheet({
    required this.values,
    required this.selected,
    required this.itemLabel,
  });
  final List<T> values;
  final Set<T> selected;
  final String Function(T) itemLabel;
  @override
  State<_FilterSheet<T>> createState() => _FilterSheetState<T>();
}

class _FilterSheetState<T> extends State<_FilterSheet<T>> {
  late Set<T> selected = {...widget.selected};
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final value in widget.values)
                  CheckboxListTile(
                    value: selected.contains(value),
                    title: Text(widget.itemLabel(value)),
                    onChanged: (checked) => setState(
                      () => checked == true
                          ? selected.add(value)
                          : selected.remove(value),
                    ),
                  ),
              ],
            ),
          ),
          FilledButton(
            key: const Key('explore_filter_apply'),
            onPressed: () => Navigator.pop(context, selected),
            child: Text(strings.exploreApply),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.card, required this.onTap});
  final ExploreRoutineCard card;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: card.name,
      child: Card(
        child: InkWell(
          key: Key('explore_routine_${card.routineId}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  card.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      strings.recommendationDurationMinutes(
                        (card.durationSeconds / 60).ceil(),
                      ),
                      key: const Key('explore_card_duration'),
                    ),
                    Text(_difficultyLabel(strings, card.difficulty)),
                    Text(
                      strings.recommendationMovementsCount(card.movementCount),
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

class _ExploreEmpty extends StatelessWidget {
  const _ExploreEmpty({required this.hasFilters, required this.onClear});
  final bool hasFilters;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore_off_outlined, size: 48),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      hasFilters
                          ? strings.exploreEmptyFilteredTitle
                          : strings.exploreEmptyTitle,
                      key: const Key('explore_empty_title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasFilters
                        ? strings.exploreEmptyFilteredBody
                        : strings.exploreEmptyBody,
                    textAlign: TextAlign.center,
                  ),
                  if (hasFilters)
                    TextButton(
                      key: const Key('explore_empty_clear'),
                      onPressed: onClear,
                      child: Text(strings.exploreClear),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreError extends StatelessWidget {
  const _ExploreError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.exploreError),
          FilledButton(onPressed: onRetry, child: Text(strings.retry)),
        ],
      ),
    );
  }
}

class _CategoryError extends StatelessWidget {
  const _CategoryError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: 8),
          Expanded(child: Text(strings.exploreCategoriesError)),
          TextButton(
            key: const Key('explore_categories_retry'),
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}

String _bodyLabel(AppLocalizations s, String key) => switch (key) {
  'neck' => s.checkInAreaNeck,
  'shoulders' => s.checkInAreaShoulders,
  'upper_back' => s.checkInAreaUpperBack,
  'lower_back' => s.checkInAreaLowerBack,
  'hips' => s.checkInAreaHips,
  'knees' => s.checkInAreaKnees,
  _ => s.checkInAreaFullBody,
};
String _positionLabel(AppLocalizations s, String key) => switch (key) {
  'seated' => s.checkInPositionSeated,
  'standing' => s.checkInPositionStanding,
  _ => s.checkInPositionFloor,
};
String _difficultyLabel(AppLocalizations s, DifficultyLevel value) =>
    switch (value) {
      DifficultyLevel.beginner => s.recommendationDifficultyBeginner,
      DifficultyLevel.intermediate => s.recommendationDifficultyIntermediate,
      DifficultyLevel.advanced => s.recommendationDifficultyAdvanced,
    };
