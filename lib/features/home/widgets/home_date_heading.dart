import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDateHeading extends StatelessWidget {
  const HomeDateHeading({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Align(
      alignment: Alignment.topRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DateFormat('d MMMM', locale).format(date),
            key: const Key('home_date'),
            textAlign: TextAlign.right,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              DateFormat.EEEE(locale).format(date),
              key: const Key('home_day'),
              textAlign: TextAlign.right,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
