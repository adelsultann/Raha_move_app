import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/explore_providers.dart';
import 'widgets/routine_details_content.dart';
import 'widgets/routine_details_unavailable.dart';
import 'widgets/routine_start_bar.dart';

class ExploreRoutineDetailsScreen extends ConsumerStatefulWidget {
  const ExploreRoutineDetailsScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<ExploreRoutineDetailsScreen> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<ExploreRoutineDetailsScreen> {
  final Map<String, int> durations = {};
  String get routineId => widget.routineId;
  @override
  Widget build(BuildContext context) {
    final details = ref.watch(exploreRoutineDetailsProvider(routineId));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          details.asData?.value?.presentation.name ?? '',
          key: const Key('explore_details_name'),
        ),
      ),
      bottomNavigationBar: details.asData?.value == null
          ? null
          : RoutineStartBar(
              details: details.asData!.value!,
              durations: jsonEncode(durations),
            ),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => RoutineDetailsUnavailable(
          onRetry: () =>
              ref.invalidate(exploreRoutineDetailsProvider(routineId)),
        ),
        data: (value) => value == null
            ? RoutineDetailsUnavailable(
                onRetry: () =>
                    ref.invalidate(exploreRoutineDetailsProvider(routineId)),
              )
            : RoutineDetailsContent(
                details: value,
                durations: durations,
                onChange: (id, seconds) =>
                    setState(() => durations[id] = seconds),
              ),
      ),
    );
  }
}
