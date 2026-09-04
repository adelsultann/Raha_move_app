import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';

import '../application/saved_routines_providers.dart';
import '../domain/saved_routine.dart';

class SavedRoutinesScreen extends ConsumerWidget {
  const SavedRoutinesScreen({super.key, this.onOpenRoutine});

  final ValueChanged<String>? onOpenRoutine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final routines = ref.watch(savedRoutinesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.savedRoutinesTitle)),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _SavedError(onRetry: () => ref.invalidate(savedRoutinesProvider)),
        data: (items) => items.isEmpty
            ? const _SavedEmpty()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _SavedCard(item: items[index], onOpen: onOpenRoutine),
              ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.item, this.onOpen});
  final SavedRoutine item;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final unavailable = !item.isPlayable;
    return Semantics(
      button: !unavailable,
      label: unavailable
          ? strings.savedRoutinesUnavailableSemantics(item.title)
          : item.title,
      child: Card(
        child: ListTile(
          key: Key('saved_routine_${item.routineId}'),
          title: Text(item.title),
          subtitle: unavailable
              ? Text(
                  strings.savedRoutinesUnavailableBody,
                  key: const Key('saved_routine_unavailable_message'),
                )
              : null,
          trailing: unavailable ? const Icon(Icons.info_outline) : null,
          onTap: unavailable
              ? null
              : () {
                  if (onOpen != null) {
                    onOpen!(item.routineId);
                  } else {
                    ExploreRoutineDetailsRoute(routineId: item.routineId)
                        .push(context);
                  }
                },
        ),
      ),
    );
  }
}

class _SavedEmpty extends StatelessWidget {
  const _SavedEmpty();
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
                  const Icon(Icons.bookmark_border, size: 48),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      strings.savedRoutinesEmptyTitle,
                      key: const Key('saved_routines_empty_title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.savedRoutinesEmptyBody,
                    textAlign: TextAlign.center,
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

class _SavedError extends StatelessWidget {
  const _SavedError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.savedRoutinesError),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('saved_routines_retry'),
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}
