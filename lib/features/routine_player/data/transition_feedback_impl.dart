import 'dart:async';

import 'package:flutter/services.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/playback_support.dart';

/// [TransitionFeedback] using Flutter's built-in [SystemSound] (click) and
/// [HapticFeedback] (light impact). It is gated by the active user's
/// `sound_enabled`/`vibration_enabled` preferences (defaulting to true when the
/// preference row is absent) and, because both primitives honor the OS
/// mute/haptics settings, the OS settings are respected automatically.
final class DefaultTransitionFeedback implements TransitionFeedback {
  DefaultTransitionFeedback(this._database, {required this.activeUserId});

  final AppDatabase _database;

  /// Resolves the active local user id lazily so feedback is a no-op while the
  /// identity is still initializing.
  final String? Function() activeUserId;

  @override
  void onStepTransition() {
    final userId = activeUserId();
    if (userId == null) return;
    unawaited(_playFor(userId));
  }

  Future<void> _playFor(String userId) async {
    final prefs = await (_database.select(
      _database.localUserPreferences,
    )..where((r) => r.userId.equals(userId))).getSingleOrNull();
    final soundEnabled = prefs?.soundEnabled ?? true;
    final vibrationEnabled = prefs?.vibrationEnabled ?? true;
    try {
      if (soundEnabled) {
        await SystemSound.play(SystemSoundType.click);
      }
      if (vibrationEnabled) {
        await HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Both primitives are best-effort; failures are intentionally ignored.
    }
  }
}
