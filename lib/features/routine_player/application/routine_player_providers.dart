import 'dart:ui' show Locale;

import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_routine_playback_loader.dart';
import '../data/drift_routine_session_repository.dart';
import '../data/screen_wake_lock_impl.dart';
import '../data/transition_feedback_impl.dart';
import '../domain/playback_plan.dart';
import '../domain/playback_support.dart';
import '../domain/playback_ticker.dart';
import '../domain/routine_playback_loader.dart';
import '../domain/routine_session_repository.dart';

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

/// Injectable clock for deterministic session timing in tests.
@riverpod
DateTime Function() routinePlayerClock(Ref ref) => DateTime.now;

/// App-owned local session persistence. Tests override this with a fake to
/// isolate orchestration from the Drift database.
@riverpod
RoutineSessionRepository routineSessionRepository(Ref ref) {
  return DriftRoutineSessionRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(routinePlayerClockProvider),
  );
}

/// The most recently active in-progress session for the current user. Watched
/// by the player's start gate so an ordinary new start detects a conflicting
/// session and offers resume or abandon. Stale (>24h) sessions are expired
/// first so they can never block or be restored.
@riverpod
Future<RoutineSessionSnapshot?> resumableRoutineSession(Ref ref) async {
  final auth = await ref.watch(authControllerProvider.future);
  final userId = auth.activeUserId;
  if (userId == null) return null;
  final repository = ref.read(routineSessionRepositoryProvider);
  await repository.expireInactiveSessions(userId: userId);
  return repository.resumable(userId: userId);
}

/// A specific session by stable id, used to restore a session after a restart.
/// Stale (>24h) sessions are expired first so they can never be restored.
@riverpod
Future<RoutineSessionSnapshot?> routineSessionById(
  Ref ref,
  String sessionId,
) async {
  final auth = await ref.watch(authControllerProvider.future);
  final userId = auth.activeUserId;
  if (userId == null) return null;
  final repository = ref.read(routineSessionRepositoryProvider);
  await repository.expireInactiveSessions(userId: userId);
  return repository.findById(userId: userId, sessionId: sessionId);
}
