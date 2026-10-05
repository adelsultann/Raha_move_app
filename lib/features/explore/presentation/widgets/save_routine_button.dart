import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/saved_routines/application/saved_routine_controller.dart';

class SaveRoutineButton extends ConsumerWidget {
  const SaveRoutineButton({super.key, required this.routineId});
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
