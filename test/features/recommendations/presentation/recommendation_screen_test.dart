import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/recommendations/presentation/recommendation_screen.dart';

import '../support/recommendation_test_harness.dart';

void main() {
  testWidgets('renders the recommendation with name, chips, why, and actions', (
    tester,
  ) async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seated neck reset'), findsOneWidget);
    expect(find.text('Why this routine?'), findsOneWidget);
    expect(find.text('Fits your 5 minutes.'), findsOneWidget);
    expect(find.text('Start routine'), findsOneWidget);
    expect(find.text('Choose another'), findsOneWidget);
    expect(find.text('Preview movements'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Seated'), findsOneWidget);
    expect(find.text('No equipment'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('invokes start and choose-another callbacks', (tester) async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    var started = false;
    var choseAnother = false;
    await tester.pumpWidget(
      _wrap(
        container,
        RecommendationScreen(
          checkInId: 'check-in-1',
          onStart: () => started = true,
          onChooseAnother: () => choseAnother = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recommendation_start')));
    expect(started, isTrue);

    await tester.tap(find.byKey(const Key('recommendation_choose_another')));
    expect(choseAnother, isTrue);
  });

  testWidgets('opens a concise movement preview without forcing inspection', (
    tester,
  ) async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('recommendation_preview')));
    await tester.pumpAndSettle();

    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('Seated neck release'), findsOneWidget);
  });

  testWidgets('renders in Arabic RTL without overflow', (tester) async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(
      db,
      language: AppLanguage.ar,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        RecommendationScreen(checkInId: 'check-in-1'),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('استراحة للرقبة أثناء الجلوس'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a clear retry state when no candidate matches', (
    tester,
  ) async {
    final db = await seedRecommendationDatabase(
      checkInAnswers: CheckInAnswers(
        bodyState: BodyState.stiff,
        goalKey: 'ease_stiffness',
        bodyAreaKeys: const {'neck'},
        availableMinutes: 5,
        positionKey: 'floor',
      ),
    );
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("We couldn't find a matching routine yet."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows a retry state when the check-in is missing', (
    tester,
  ) async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-missing')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("We couldn't prepare your recommendation right now."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('remains usable at 200% text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-1')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a compact screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, RecommendationScreen(checkInId: 'check-in-1')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(ProviderContainer container, Widget child, {Locale? locale}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
