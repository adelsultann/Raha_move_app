import 'package:flutter/material.dart';

import '../../domain/explore_models.dart';
import 'routine_start_button.dart';

class RoutineStartBar extends StatelessWidget {
  const RoutineStartBar({
    super.key,
    required this.details,
    required this.durations,
  });
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
            child: RoutineStartButton(
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
