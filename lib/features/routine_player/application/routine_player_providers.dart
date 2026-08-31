import 'dart:ui' show Locale;

import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_routine_playback_loader.dart';
import '../data/screen_wake_lock_impl.dart';
import '../data/transition_feedback_impl.dart';
import '../domain/playback_plan.dart';
import '../domain/playback_support.dart';
import '../domain/playback_ticker.dart';
import '../domain/routine_playback_loader.dart';

part 'routine_player_providers.g.dart';

/// Loads the localized playback plan from the local Drift content cache.
/// Tests override this with a fake to isolate orchestration from persistence.
@Riverpod(keepAlive: true)
RoutinePlaybackLoader routinePlaybackLoader(Ref ref) =>
    DriftRoutinePlaybackLoader(ref.watch(appDatabaseProvider));

/// The localized playback plan for one routine, re-resolved whenever the active
/// locale changes.
@riverpod
Future<RoutinePlaybackPlan> routinePlaybackPlan(
  Ref ref,
  String routineId,
) async {
  final locale =
      ref.watch(localeControllerProvider).value ?? const Locale('en');
  return ref
      .read(routinePlaybackLoaderProvider)
      .load(routineId, locale.languageCode);
}

/// Keep-awake boundary. Tests override this with a recording fake.
@riverpod
ScreenWakeLock screenWakeLock(Ref ref) => const WakelockScreenWakeLock();

/// Transition sound/vibration boundary, gated by the active user's preferences.
/// Tests override this with a recording fake.
@riverpod
TransitionFeedback transitionFeedback(Ref ref) => DefaultTransitionFeedback(
  ref.watch(appDatabaseProvider),
  activeUserId: () => ref.read(authControllerProvider).value?.activeUserId,
);

/// A fresh one-second ticker per controller instance. Stopped on dispose.
@riverpod
PlaybackTicker playbackTicker(Ref ref) {
  final ticker = PeriodicPlaybackTicker();
  ref.onDispose(ticker.stop);
  return ticker;
}
