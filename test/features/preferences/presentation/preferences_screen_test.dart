import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/preferences/application/preferences_controller.dart';
import 'package:raha_move/features/preferences/presentation/preferences_screen.dart';

import '../support/preferences_test_harness.dart';

void main() {
  testWidgets('continue is disabled until experience is selected', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      _wrap(
        buildPreferencesContainer(),
        PreferencesScreen(onBack: () {}, onComplete: () => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('preferences_continue')),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text('Choose your experience level to continue.'),
      findsOneWidget,
    );
    expect(completed, isFalse);
  });

  testWidgets(
    'selecting experience, positions, goal, and reminder then saves',
    (tester) async {
      var completed = false;
      final repository = FakePreferencesRepository();
      await tester.pumpWidget(
        _wrap(
          buildPreferencesContainer(repository: repository),
          PreferencesScreen(onBack: () {}, onComplete: () => completed = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('preferences_experience_beginner')),
      );
      await tester.tap(
        find.byKey(const Key('preferences_experience_beginner')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('preferences_position_seated')),
      );
      await tester.tap(find.byKey(const Key('preferences_position_seated')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('preferences_weekly_goal_increment')),
      );
      await tester.tap(
        find.byKey(const Key('preferences_weekly_goal_increment')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('preferences_reminder_toggle')),
      );
      await tester.tap(find.byKey(const Key('preferences_reminder_toggle')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('preferences_continue')));
      await tester.tap(find.byKey(const Key('preferences_continue')));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(repository.savedFor, 'guest-1');
      expect(repository.stored, isNotNull);
      expect(repository.stored!.experienceLevel.code, 'beginner');
      expect(repository.stored!.preferredPositions.map((p) => p.key), {
        'seated',
      });
      expect(repository.stored!.weeklyGoalDays, 4);
      expect(repository.stored!.reminderInterest, isTrue);
    },
  );

  testWidgets(
    'shows a save error and does not complete on persistence failure',
    (tester) async {
      var completed = false;
      final repository = FakePreferencesRepository()
        ..saveError = StateError('boom');
      await tester.pumpWidget(
        _wrap(
          buildPreferencesContainer(repository: repository),
          PreferencesScreen(onBack: () {}, onComplete: () => completed = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('preferences_experience_beginner')),
      );
      await tester.tap(
        find.byKey(const Key('preferences_experience_beginner')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('preferences_continue')));
      await tester.tap(find.byKey(const Key('preferences_continue')));
      await tester.pumpAndSettle();

      expect(completed, isFalse);
      expect(
        find.text("We couldn't save your preferences. Please try again."),
        findsOneWidget,
      );
    },
  );

  testWidgets('back invokes onBack and keeps the draft in the controller', (
    tester,
  ) async {
    var wentBack = false;
    final container = buildPreferencesContainer();
    await tester.pumpWidget(
      _wrap(
        container,
        PreferencesScreen(onBack: () => wentBack = true, onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('preferences_experience_beginner')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preferences_back')));
    await tester.pumpAndSettle();

    expect(wentBack, isTrue);
    expect(
      container.read(preferencesControllerProvider).experienceLevel?.code,
      'beginner',
    );
  });

  testWidgets('renders in Arabic RTL without overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        buildPreferencesContainer(),
        PreferencesScreen(onBack: () {}, onComplete: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تفضيلات سريعة'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains usable at 200% text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _wrap(
        buildPreferencesContainer(),
        PreferencesScreen(onBack: () {}, onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a compact screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        buildPreferencesContainer(),
        PreferencesScreen(onBack: () {}, onComplete: () {}),
      ),
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
      home: Scaffold(body: child),
    ),
  );
}
