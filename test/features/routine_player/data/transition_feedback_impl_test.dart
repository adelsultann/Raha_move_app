import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/routine_player/data/transition_feedback_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late _AudioPlayer player;
  late DefaultTransitionFeedback feedback;
  late Completer<void> vibration;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final now = DateTime.utc(2026, 10, 5);
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            userId: 'user',
            preferredLocale: 'en',
            timezone: 'Asia/Riyadh',
            weeklyGoalDays: 3,
            localUpdatedAt: now,
          ),
        );
    await database
        .into(database.localUserPreferences)
        .insert(
          LocalUserPreferencesCompanion.insert(
            userId: 'user',
            experienceLevel: 'beginner',
            localUpdatedAt: now,
          ),
        );
    player = _AudioPlayer();
    vibration = Completer<void>();
    feedback = DefaultTransitionFeedback(
      database,
      activeUserId: () => 'user',
      player: player,
      vibrate: () => vibration.future,
    );
  });

  tearDown(() async {
    if (!vibration.isCompleted) vibration.complete();
    await feedback.dispose();
    await database.close();
  });

  test(
    'preloads once and plays without awaiting vibration or loading again',
    () async {
      await feedback.prepare();
      await feedback.prepare();
      expect(player.sourceLoads, 1);
      expect(player.source, isA<AssetSource>());
      expect(
        (player.source as AssetSource).path,
        'audio/exercise_transition.wav',
      );
      expect(player.releaseMode, ReleaseMode.stop);
      feedback.onStepTransition();
      await pumpEventQueue();
      expect(vibration.isCompleted, isFalse);
      expect(player.resumes, 1);
      feedback.onStepTransition();
      await pumpEventQueue();
      expect(player.resumes, 2);
      expect(player.sourceLoads, 1);
    },
  );

  test('cached preferences still reflect turning sound off', () async {
    await feedback.prepare();
    await pumpEventQueue();
    await (database.update(database.localUserPreferences)
          ..where((r) => r.userId.equals('user')))
        .write(const LocalUserPreferencesCompanion(soundEnabled: Value(false)));
    await pumpEventQueue();
    feedback.onStepTransition();
    await pumpEventQueue();
    expect(player.resumes, 0);
  });

  test('missing audio device does not block preparation', () async {
    player.failPrepare = true;
    await feedback.prepare();
    feedback.onStepTransition();
    await pumpEventQueue();
    expect(player.resumes, 0);
  });
}

class _AudioPlayer implements AudioPlayer {
  int sourceLoads = 0;
  int resumes = 0;
  bool failPrepare = false;
  @override
  Source? source;
  @override
  ReleaseMode releaseMode = ReleaseMode.release;

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    releaseMode = mode;
  }

  @override
  Future<void> setAudioContext(AudioContext context) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setSource(Source source) async {
    if (failPrepare) throw StateError('no audio device');
    sourceLoads++;
    this.source = source;
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> resume() async {
    resumes++;
  }

  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
