import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/playback_support.dart';

/// App-owned, offline chime and haptics, gated by the active user's preferences.
final class DefaultTransitionFeedback implements TransitionFeedback {
  DefaultTransitionFeedback(this._database, {required this.activeUserId});

  final AppDatabase _database;
  final String? Function() activeUserId;
  final AudioPlayer _player = AudioPlayer();
  bool _disposed = false;

  Future<void> dispose() async {
    _disposed = true;
    await _player.dispose();
  }

  @override
  void onStepTransition() {
    final userId = activeUserId();
    if (userId != null && !_disposed) unawaited(_playFor(userId));
  }

  Future<void> _playFor(String userId) async {
    try {
      final prefs = await (_database.select(
        _database.localUserPreferences,
      )..where((r) => r.userId.equals(userId))).getSingleOrNull();
      if (_disposed || activeUserId() != userId) return;
      if (prefs?.vibrationEnabled ?? true) {
        try {
          await HapticFeedback.lightImpact();
        } catch (_) {
          /* Best effort. */
        }
      }
      if (!_disposed && (prefs?.soundEnabled ?? true)) {
        await _player.play(
          AssetSource('audio/exercise_transition.wav'),
          ctx: AudioContext(
            android: const AudioContextAndroid(
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          ),
          volume: .55,
        );
      }
    } catch (_) {
      // A missing audio device or preference read must never stop a routine.
    }
  }
}
