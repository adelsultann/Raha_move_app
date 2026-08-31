/// Keeps the screen awake during active playback. The production implementation
/// wraps `wakelock_plus`; tests use a fake so the native plugin never leaks into
/// domain or presentation logic.
abstract interface class ScreenWakeLock {
  Future<void> enable();
  Future<void> disable();
}

/// Calm, best-effort feedback on step transitions (sound and vibration), gated
/// by the user's sound/vibration preferences. The production implementation uses
/// Flutter's built-in [SystemSound] and [HapticFeedback], which honor the OS
/// mute/haptics settings automatically.
abstract interface class TransitionFeedback {
  void onStepTransition();
}
