import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';

import '../../domain/explore_models.dart';

class RoutineStartButton extends ConsumerWidget {
  const RoutineStartButton({
    super.key,
    required this.routineId,
    required this.eligibility,
    required this.durations,
  });
  final String durations;
  final String routineId;
  final RoutineStartEligibility eligibility;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(transitionFeedbackReadyProvider);
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
