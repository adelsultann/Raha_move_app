import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

class ProgressProvisionalBanner extends StatelessWidget {
  const ProgressProvisionalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined),
              const SizedBox(width: 8),
              Expanded(child: Text(s.progressLocalPending)),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressEmptyState extends StatelessWidget {
  const ProgressEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          const Icon(Icons.self_improvement_outlined, size: 48),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              s.progressEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(s.progressEmptyBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ProgressErrorState extends StatelessWidget {
  const ProgressErrorState({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.progressError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('progress_retry'),
              onPressed: onRetry,
              child: Text(s.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressLoadingState extends StatelessWidget {
  const ProgressLoadingState({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(key: Key('progress_loading')),
  );
}
