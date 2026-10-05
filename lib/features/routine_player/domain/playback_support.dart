/// Keeps the screen awake during active playback. The production implementation
/// wraps `wakelock_plus`; tests use a fake so the native plugin never leaks into
/// domain or presentation logic.
abstract interface class ScreenWakeLock {
  Future<void> enable();
  Future<void> disable();
}

/// Calm, best-effort feedback at routine start and step transitions, gated by
/// the user's sound/vibration preferences. Production plays the bundled
/// three-second transition audio and uses the platform's light haptic feedback.
abstract interface class TransitionFeedback {
  void onStepTransition();
}
