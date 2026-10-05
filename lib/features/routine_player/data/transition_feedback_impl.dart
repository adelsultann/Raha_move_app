import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/playback_support.dart';

/// Keeps the bundled chime ready so cue playback performs no asset loading,
/// database query, or wait for haptics.
final class DefaultTransitionFeedback implements TransitionFeedback {
  DefaultTransitionFeedback(
    this._database, {
    required this.activeUserId,
    AudioPlayer? player,
    Future<void> Function()? vibrate,
  }) : _player = player ?? AudioPlayer(),
       _vibrate = vibrate ?? HapticFeedback.lightImpact;

  final AppDatabase _database;
  final String? Function() activeUserId;
  final AudioPlayer _player;
  final Future<void> Function() _vibrate;
  StreamSubscription<LocalUserPreference?>? _preferencesSubscription;
  LocalUserPreference? _preferences;
  String? _preparedUserId;
  Future<void>? _preparing;
  bool _audioReady = false;
  bool _disposed = false;

  @override
  Future<void> prepare() => _preparing ??= _prepare();

  Future<void> _prepare() async {
    final userId = activeUserId();
    if (userId == null || _disposed) return;
    _preparedUserId = userId;
    try {
      final query = _database.select(_database.localUserPreferences)
        ..where((r) => r.userId.equals(userId));
      _preferences = await query.getSingleOrNull();
      if (_disposed) return;
      _preferencesSubscription = query.watchSingleOrNull().listen(
        (preferences) => _preferences = preferences,
        onError: (Object _, StackTrace _) {},
      );
      // Keep the decoded asset after completion instead of releasing it.
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
        ),
      );
      await _player.setVolume(.55);
      await _player.setSource(AssetSource('audio/exercise_transition.wav'));
      _audioReady = !_disposed;
    } catch (_) {
      // Audio remains best effort; unavailable devices never block a routine.
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _preferencesSubscription?.cancel();
    await _player.dispose();
  }

  @override
  void onStepTransition() {
    if (_disposed || activeUserId() != _preparedUserId) return;
    if (_audioReady && (_preferences?.soundEnabled ?? true)) {
      unawaited(_play());
    }
    // Vibration must never delay the audio cue.
    if (_preferences?.vibrationEnabled ?? true) {
      unawaited(_vibrateSafely());
    }
  }

  Future<void> _play() async {
    try {
      // stop rewinds without releasing the prepared asset. This also makes a
      // manual skip restart an in-flight cue instead of overlapping it.
      await _player.stop();
      if (!_disposed) await _player.resume();
    } catch (_) {
      // Missing or interrupted audio devices must not stop playback.
    }
  }

  Future<void> _vibrateSafely() async {
    try {
      await _vibrate();
    } catch (_) {
      // Haptics are best effort too.
    }
  }
}
