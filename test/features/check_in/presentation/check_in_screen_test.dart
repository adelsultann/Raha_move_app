import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/check_in/application/check_in_controller.dart';
import 'package:raha_move/features/check_in/domain/body_area.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/presentation/check_in_screen.dart';

import '../support/check_in_test_harness.dart';

void main() {
  testWidgets('continue is disabled until the current step is answered', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      _wrap(
        buildCheckInContainer(),
        CheckInScreen(onExit: () {}, onComplete: () => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How does your body feel today?'), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('check_in_continue')))
          .onPressed,
      isNull,
    );
    expect(find.text('Please choose an answer to continue.'), findsOneWidget);
    expect(completed, isFalse);
  });

  testWidgets('completes all five steps and persists one check-in', (
    tester,
  ) async {
    var completed = false;
    final repository = FakeCheckInRepository();
    await tester.pumpWidget(
      _wrap(
        buildCheckInContainer(repository: repository),
        CheckInScreen(onExit: () {}, onComplete: () => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    await _answerBodyState(tester);
    await _answerGoal(tester);
    await _answerAreas(tester);
    await _answerTime(tester);
    await _answerPosition(tester);

    expect(completed, isTrue);
    expect(repository.savedFor, 'guest-1');
    expect(repository.saveCount, 1);
    expect(repository.savedAnswers!.bodyState, BodyState.stiff);
    expect(repository.savedAnswers!.goalKey, 'ease_stiffness');
    expect(repository.savedAnswers!.bodyAreaKeys, {'neck', 'shoulders'});
    expect(repository.savedAnswers!.availableMinutes, 5);
    expect(repository.savedAnswers!.positionKey, 'seated');
  });

  testWidgets('body areas support multi-select', (tester) async {
    final container = buildCheckInContainer();
    await tester.pumpWidget(
      _wrap(container, CheckInScreen(onExit: () {}, onComplete: () {})),
    );
    await tester.pumpAndSettle();

    await _answerBodyState(tester);
    await _answerGoal(tester);

    await tester.ensureVisible(find.byKey(const Key('check_in_area_neck')));
    await tester.tap(find.byKey(const Key('check_in_area_neck')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('check_in_area_hips')));
    await tester.tap(find.byKey(const Key('check_in_area_hips')));
    await tester.pumpAndSettle();

    final form = container.read(checkInControllerProvider);
    expect(form.bodyAreas, {BodyArea.neck, BodyArea.hips});
  });

  testWidgets('back preserves answers and a changed answer is reflected', (
    tester,
  ) async {
    final container = buildCheckInContainer();
    await tester.pumpWidget(
      _wrap(container, CheckInScreen(onExit: () {}, onComplete: () {})),
    );
    await tester.pumpAndSettle();

    await _answerBodyState(tester);
    expect(
      container.read(checkInControllerProvider).bodyState,
      BodyState.stiff,
    );

    // Go back to step 1 and change the body-state answer.
    await tester.tap(find.byKey(const Key('check_in_back')));
    await tester.pumpAndSettle();
    expect(find.text('How does your body feel today?'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('check_in_body_state_tense')),
    );
    await tester.tap(find.byKey(const Key('check_in_body_state_tense')));
    await tester.pumpAndSettle();

    expect(
      container.read(checkInControllerProvider).bodyState,
      BodyState.tense,
    );
  });

  testWidgets('shows a save error and does not complete on failure', (
    tester,
  ) async {
    var completed = false;
    final repository = FakeCheckInRepository()..saveError = StateError('boom');
    await tester.pumpWidget(
      _wrap(
        buildCheckInContainer(repository: repository),
        CheckInScreen(onExit: () {}, onComplete: () => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    await _answerBodyState(tester);
    await _answerGoal(tester);
    await _answerAreas(tester);
    await _answerTime(tester);
    await _answerPosition(tester);

    expect(completed, isFalse);
    expect(
      find.text("We couldn't save your check-in. Please try again."),
      findsOneWidget,
    );
  });

  testWidgets('renders in Arabic RTL without overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        buildCheckInContainer(),
        CheckInScreen(onExit: () {}, onComplete: () {}),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('كيف يشعر جسمك اليوم؟'), findsOneWidget);
    expect(find.text('الخطوة 1 من 5'), findsOneWidget);
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
        buildCheckInContainer(),
        CheckInScreen(onExit: () {}, onComplete: () {}),
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
        buildCheckInContainer(),
        CheckInScreen(onExit: () {}, onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    // Reach the multi-select area step, the longest list, and verify no
    // overflow at the compact size.
    await _answerBodyState(tester);
    await _answerGoal(tester);
    expect(find.text('Which areas need attention?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in English LTR with directionality preserved', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        buildCheckInContainer(),
        CheckInScreen(onExit: () {}, onComplete: () {}),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How does your body feel today?'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('restores prior answers after leaving and re-entering the flow', (
    tester,
  ) async {
    final container = buildCheckInContainer();
    await tester.pumpWidget(
      _wrap(container, CheckInScreen(onExit: () {}, onComplete: () {})),
    );
    await tester.pumpAndSettle();

    await _answerBodyState(tester);
    expect(
      container.read(checkInControllerProvider).bodyState,
      BodyState.stiff,
    );

    // Leave the flow entirely, then re-enter with the same container. The
    // keepAlive controller retains the draft answers across the interruption.
    await tester.pumpWidget(_wrap(container, const SizedBox()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _wrap(container, CheckInScreen(onExit: () {}, onComplete: () {})),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(checkInControllerProvider).bodyState,
      BodyState.stiff,
    );
  });
}

Future<void> _answerBodyState(WidgetTester tester) async {
  await tester.ensureVisible(
    find.byKey(const Key('check_in_body_state_stiff')),
  );
  await tester.tap(find.byKey(const Key('check_in_body_state_stiff')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('check_in_continue')));
  await tester.pumpAndSettle();
}

Future<void> _answerGoal(WidgetTester tester) async {
  await tester.ensureVisible(
    find.byKey(const Key('check_in_goal_ease_stiffness')),
  );
  await tester.tap(find.byKey(const Key('check_in_goal_ease_stiffness')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('check_in_continue')));
  await tester.pumpAndSettle();
}

Future<void> _answerAreas(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('check_in_area_neck')));
  await tester.tap(find.byKey(const Key('check_in_area_neck')));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('check_in_area_shoulders')));
  await tester.tap(find.byKey(const Key('check_in_area_shoulders')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('check_in_continue')));
  await tester.pumpAndSettle();
}

Future<void> _answerTime(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('check_in_time_5')));
  await tester.tap(find.byKey(const Key('check_in_time_5')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('check_in_continue')));
  await tester.pumpAndSettle();
}

Future<void> _answerPosition(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('check_in_position_seated')));
  await tester.tap(find.byKey(const Key('check_in_position_seated')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('check_in_continue')));
  await tester.pumpAndSettle();
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
