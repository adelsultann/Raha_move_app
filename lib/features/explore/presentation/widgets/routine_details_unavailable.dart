import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

class RoutineDetailsUnavailable extends StatelessWidget {
  const RoutineDetailsUnavailable({super.key, required this.onRetry});
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
