import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';

import '../application/explore_providers.dart';
import '../domain/explore_models.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key, this.initialBodyArea});

  /// Retained for existing Home links; MVP browsing always shows all routines.
  final String? initialBodyArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final provider = exploreRoutinesProvider(filters: const ExploreFilters());
    final routines = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.exploreTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: routines.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _ExploreStatus(
                icon: Icons.cloud_off_outlined,
                title: strings.exploreError,
                action: FilledButton.icon(
                  key: const Key('explore_retry'),
                  onPressed: () => ref.invalidate(provider),
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.retry),
                ),
              ),
              data: (items) => CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.exploreIntro,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            key: const Key('explore_saved_routines'),
                            onPressed: () =>
                                const SavedRoutinesRoute().push(context),
                            icon: const Icon(Icons.bookmark_outline),
                            label: Text(strings.savedRoutinesOpen),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: _ExploreStatus(
                        icon: Icons.self_improvement_outlined,
                        title: strings.exploreEmptyTitle,
                        body: strings.exploreEmptyBody,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _RoutineCard(
                          card: items[index],
                          onTap: () => ExploreRoutineDetailsRoute(
                            routineId: items[index].routineId,
                          ).push(context),
                        ),
                      ),
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

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.card, required this.onTap});
  final ExploreRoutineCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      button: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('explore_routine_${card.routineId}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 20,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.recommendationDurationMinutes(
                          (card.durationSeconds / 60).ceil(),
                        ),
                        key: const Key('explore_card_duration'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(card.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  card.summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text(
                      _difficultyLabel(strings, card.difficulty),
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      strings.recommendationMovementsCount(card.movementCount),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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

class _ExploreStatus extends StatelessWidget {
  const _ExploreStatus({
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(body!, textAlign: TextAlign.center),
                ],
                if (action != null) ...[const SizedBox(height: 20), action!],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String _difficultyLabel(AppLocalizations s, DifficultyLevel value) =>
    switch (value) {
      DifficultyLevel.beginner => s.recommendationDifficultyBeginner,
      DifficultyLevel.intermediate => s.recommendationDifficultyIntermediate,
      DifficultyLevel.advanced => s.recommendationDifficultyAdvanced,
    };
