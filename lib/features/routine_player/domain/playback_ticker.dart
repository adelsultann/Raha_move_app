import 'dart:async';

/// Drives one-second playback ticks. A fake can drive ticks deterministically in
/// tests without waiting on wall-clock time.
abstract interface class PlaybackTicker {
  void start(void Function() onTick);
  void stop();
}

/// A one-second periodic ticker backed by [Timer.periodic]. Guarded against
/// re-entry: a second [start] while already ticking is a no-op.
final class PeriodicPlaybackTicker implements PlaybackTicker {
  Timer? _timer;

  @override
  void start(void Function() onTick) {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
