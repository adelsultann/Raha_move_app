import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/gamification/presentation/completion_gamification_summary.dart';

import '../application/routine_feedback_controller.dart';
import '../application/routine_feedback_state.dart';
import '../application/routine_player_controller.dart';
import '../application/routine_player_providers.dart';
import '../application/routine_player_state.dart';
import '../domain/playback_session.dart';
import '../domain/routine_feedback.dart';
import 'widgets/player_controls.dart';
import 'widgets/routine_demonstration.dart';

part 'routine_player_playback.dart';
part 'routine_player_completion.dart';
part 'routine_player_states.dart';

/// The focused, distraction-free routine player (RAHA-051/052). No bottom
/// navigation, ads, streak pressure, or unrelated actions appear here.
///
/// A null [sessionId] starts a new session (after resolving any conflicting
/// in-progress session); a non-null [sessionId] restores that session paused.
class RoutinePlayerScreen extends ConsumerStatefulWidget {
  const RoutinePlayerScreen({
    super.key,
    required this.routineId,
    this.recommendationId,
    this.sessionId,
    this.source,
    this.durations,
    this.showGamification = true,
  });

  final String routineId;
  final String? recommendationId;
  final String? sessionId;
  final String? source;
  final String? durations;
  final bool showGamification;

  @override
  ConsumerState<RoutinePlayerScreen> createState() =>
      _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends ConsumerState<RoutinePlayerScreen>
    with WidgetsBindingObserver {
  RoutinePlayerArgs get _args => RoutinePlayerArgs(
    routineId: widget.routineId,
    recommendationId: widget.recommendationId,
    sessionId: widget.sessionId,
    source: widget.source,
    durations: widget.durations,
  );

  RoutinePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.finish();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller?.pauseForBackground();
      case AppLifecycleState.resumed:
        // Stay paused; the user resumes manually.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routinePlayerControllerProvider(_args));
    _controller = ref.read(routinePlayerControllerProvider(_args).notifier);

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      failed: () => _FailedState(
        onRetry: () {
          ref.invalidate(routinePlaybackPlanProvider(widget.routineId));
          if (widget.sessionId != null) {
            ref.invalidate(routineSessionByIdProvider(widget.sessionId!));
          }
        },
      ),
      conflict: (resumable) => _ConflictState(
        onResume: () {
          RoutinePlayerRoute(
            routineId: resumable.routineId,
            sessionId: resumable.sessionId,
          ).pushReplacement(context);
        },
        onAbandonAndStart: () async {
          await _controller?.abandonAndStart();
        },
      ),
      saveError: () => _SaveErrorState(onRetry: () => _controller?.retrySave()),
      ready: (session) => _PlayerContent(
        session: session,
        controller: _controller!,
        showGamification: widget.showGamification,
      ),
    );
  }
}
