import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/theme/app_theme.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_routine_details_screen.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  late _VideoPlatform video;
  setUp(() {
    video = _VideoPlatform();
    VideoPlayerPlatform.instance = video;
  });
  tearDown(() async {
    for (final stream in video.events.values) {
      await stream.close();
    }
  });

  Future<void> pumpDetails(
    WidgetTester tester,
    Locale locale, {
    bool media = true,
  }) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final movement = MovementPreviewEntry(
      name: 'Shoulder circles',
      durationSeconds: 30,
      videoAsset: media ? 'assets/starter_content/media/videos/test.mp4' : null,
      instructions: media
          ? const ['Start comfortably.', 'Move slowly.', 'Return to the start.']
          : const [],
    );
    final details = ExploreRoutineDetails(
      presentation: RoutinePresentation(
        routineId: 'routine',
        name: 'Routine',
        summary: 'A calm routine.',
        movements: [movement],
        difficulty: DifficultyLevel.beginner,
        estimatedDurationSeconds: 30,
        positions: const {},
        equipment: const {},
      ),
      eligibility: const RoutineStartEligibility.blocked(
        RoutineStartBlock.unavailable,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exploreRoutineDetailsProvider('routine')
              .overrideWith((ref) async => details),
          transitionFeedbackReadyProvider.overrideWith((ref) async {}),
        ],
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.forLocale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const ExploreRoutineDetailsScreen(routineId: 'routine'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('thumbnail opens video and ordered steps in $locale at 200%', (
      tester,
    ) async {
      await pumpDetails(tester, locale);
      await tester.tap(find.byKey(const Key('exercise_preview_open_0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exercise_preview_sheet')), findsOneWidget);
      expect(
        video.sources.single.asset,
        'assets/starter_content/media/videos/test.mp4',
      );
      expect(video.playCalls, greaterThan(0));
      expect(video.looping, isTrue);
      expect(video.volume, 0);
      expect(
        find.text(locale.languageCode == 'ar' ? 'التعليمات' : 'Instructions'),
        findsOneWidget,
      );
      for (var i = 0; i < 3; i++) {
        await tester.ensureVisible(find.byKey(Key('exercise_instruction_$i')));
        await tester.pumpAndSettle();
      }
      expect(
        tester.getTopLeft(find.byKey(const Key('exercise_instruction_0'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('exercise_instruction_1'))).dy,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.byKey(const Key('exercise_preview_close')),
      );
      await tester.tap(find.byKey(const Key('exercise_preview_close')));
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      expect(video.disposed, contains(1));
      expect(find.byKey(const Key('exercise_preview_sheet')), findsNothing);
    });
  }

  testWidgets('sheet animates upward and dismisses by dragging down', (
    tester,
  ) async {
    await pumpDetails(tester, const Locale('en'));
    await tester.tap(find.byKey(const Key('exercise_preview_open_0')));
    await tester.pump();
    final firstY = tester.getTopLeft(find.byType(BottomSheet)).dy;
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.byType(BottomSheet)).dy, lessThan(firstY));
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.byType(BottomSheet));
    await tester.dragFrom(top + const Offset(180, 16), const Offset(0, 700));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.pump();
    await tester.runAsync(() async {
      await pumpEventQueue();
    });
    expect(video.disposed, contains(1));
  });

  testWidgets('video pauses on background and resumes only when requested', (
    tester,
  ) async {
    await pumpDetails(tester, const Locale('en'));
    await tester.tap(find.byKey(const Key('exercise_preview_open_0')));
    await tester.pumpAndSettle();
    final plays = video.playCalls;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(video.pauseCalls, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(video.playCalls, plays);
    await tester.tap(find.byKey(const Key('exercise_preview_play_pause')));
    await tester.pump();
    expect(video.playCalls, greaterThan(plays));
    await tester.tap(find.byKey(const Key('exercise_preview_close')));
    await tester.pumpAndSettle();
  });

  testWidgets('video errors show a retry and recover inside the sheet', (
    tester,
  ) async {
    await pumpDetails(tester, const Locale('en'));
    await tester.tap(find.byKey(const Key('exercise_preview_open_0')));
    await tester.pumpAndSettle();
    video.events[1]!.addError(
      PlatformException(code: 'video_error', message: 'Unavailable'),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('exercise_preview_video_retry')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('exercise_preview_video_retry')));
    await tester.runAsync(() async {
      await pumpEventQueue();
    });
    await tester.pumpAndSettle();
    expect(video.sources, hasLength(2));
    expect(
      find.byKey(const Key('exercise_preview_play_pause')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('exercise_preview_close')));
    await tester.pumpAndSettle();
  });

  testWidgets('missing media and instructions have localized fallback states', (
    tester,
  ) async {
    await pumpDetails(tester, const Locale('en'), media: false);
    await tester.tap(find.byKey(const Key('exercise_preview_open_0')));
    await tester.pumpAndSettle();
    expect(
      find.text('This demonstration is not available right now.'),
      findsOneWidget,
    );
    expect(
      find.text('Instructions are not available for this exercise yet.'),
      findsOneWidget,
    );
    expect(video.sources, isEmpty);
    await tester.tap(find.byKey(const Key('exercise_preview_close')));
    await tester.pumpAndSettle();
  });
}

class _VideoPlatform extends VideoPlayerPlatform {
  final events = <int, StreamController<VideoEvent>>{};
  final sources = <DataSource>[];
  final disposed = <int>[];
  int playCalls = 0;
  int pauseCalls = 0;
  bool looping = false;
  double volume = 1;

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    sources.add(options.dataSource);
    final id = sources.length;
    events[id] = StreamController<VideoEvent>()
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 5),
          size: const Size(400, 400),
        ),
      );
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events[playerId]!.stream;
  @override
  Future<void> setLooping(int playerId, bool looping) async {
    this.looping = looping;
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    this.volume = volume;
  }

  @override
  Future<void> play(int playerId) async {
    playCalls++;
  }

  @override
  Future<void> pause(int playerId) async {
    pauseCalls++;
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> setAllowBackgroundPlayback(bool allowed) async {}
  @override
  Future<void> setMixWithOthers(bool mix) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.white);
}
