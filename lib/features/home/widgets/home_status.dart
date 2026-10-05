import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

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

class HomeLoadingRow extends StatelessWidget {
  const HomeLoadingRow({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 150,
    child: Center(child: CircularProgressIndicator()),
  );
}
