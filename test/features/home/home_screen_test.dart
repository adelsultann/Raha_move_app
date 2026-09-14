import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_navigation_shell.dart';
import 'package:raha_move/app/theme/app_theme.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/home/home_providers.dart';
import 'package:raha_move/features/home/home_screen.dart';
import 'package:raha_move/features/today/application/today_providers.dart';

const exercise = HomeExercise(
  id: 'neck',
  name: 'Seated neck release',
  description: 'Move within a comfortable range.',
  seconds: 30,
  area: 'neck',
  routineId: 'routine',
);
const shoulder = HomeExercise(
  id: 'shoulder',
  name: 'Shoulder rolls',
  description: '',
  seconds: 30,
  area: 'shoulders',
  routineId: 'routine',
);
const card = ExploreRoutineCard(
  routineId: 'routine',
  name: 'Upper body reset',
  summary: '',
  durationSeconds: 180,
  difficulty: DifficultyLevel.beginner,
  positions: {},
  equipment: {},
  movementCount: 2,
);

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final font = Platform.environment['HOME_PREVIEW_FONT'];
    if (font != null) {
      final loader = FontLoader('Roboto')
        ..addFont(
          Future.value(ByteData.sublistView(await File(font).readAsBytes())),
        );
      await loader.load();
    }
  });

  Future<void> pumpHome(
    WidgetTester tester,
    Locale locale,
    double scale,
  ) async {
    tester.view.physicalSize = const Size(390, 940);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) => const Stream.empty()),
          exploreRoutinesProvider(filters: const ExploreFilters()).overrideWith(
            (ref) async => [
              card,
              card.copyWith(routineId: 'second', name: 'Everyday mobility'),
            ],
          ),
          exploreRoutinesProvider(
            filters: const ExploreFilters(bodyAreas: {'neck'}),
          ).overrideWith((ref) async => [card]),
          exploreCategoriesProvider.overrideWith((ref) async => []),
          homeCatalogProvider.overrideWith(
            (ref) async => const HomeCatalog(
              [exercise, shoulder],
              {
                'routine': [exercise, shoulder],
              },
            ),
          ),
          savedExerciseIdsProvider.overrideWith((ref) => Stream.value({})),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: const Key('preview'),
            child: Scaffold(
              body: const HomeScreen(),
              bottomNavigationBar: RahaNavigationBar(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomeScreen));
      for (final area in areaAssets.keys) {
        await precacheImage(AssetImage(areaAsset(area)), context);
      }
    });
    await tester.pumpAndSettle();
  }

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Home ${locale.languageCode} at $scale text scale', (
        tester,
      ) async {
        await pumpHome(tester, locale, scale);
        await tester.scrollUntilVisible(
          find.byKey(const Key('home_routines')),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('home_routines')), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (locale.languageCode == 'en' &&
            scale == 1 &&
            Platform.environment['HOME_PREVIEW_PATH'] != null) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('preview')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(Platform.environment['HOME_PREVIEW_PATH']!)
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.scrollUntilVisible(
          find.byKey(const Key('exercise_neck')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.byKey(const Key('exercise_neck'))),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('exercise_neck')));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('area tile opens a filtered catalog', (tester) async {
    await pumpHome(tester, const Locale('en'), 1);
    await tester.ensureVisible(find.byKey(const Key('home_area_neck')));
    await tester.tap(find.byKey(const Key('home_area_neck')));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(find.text('Body area (1)'), findsOneWidget);
    expect(find.byKey(const Key('explore_routine_routine')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
