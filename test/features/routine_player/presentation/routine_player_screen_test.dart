import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';
import 'package:raha_move/features/routine_player/presentation/routine_player_screen.dart';

import '../support/routine_player_test_harness.dart';

void main() {
  testWidgets('renders movement name, position, and timer (English LTR)', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    expect(find.text('Neck release'), findsOneWidget);
    expect(find.byKey(const Key('player_movement_name')), findsOneWidget);
    expect(find.text('Movement 1 of 2'), findsOneWidget);
    expect(find.byKey(const Key('player_timer')), findsOneWidget);
    expect(find.text('0:03'), findsOneWidget);
    expect(find.text('Up next: Shoulder circles'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('pause toggles to resume and shows paused semantics', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    expect(find.byKey(const Key('player_paused')), findsNothing);

    await tester.tap(find.byKey(const Key('player_pause')));
    await tester.pump();
    expect(find.byKey(const Key('player_paused')), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.byKey(const Key('player_pause')));
    await tester.pump();
    expect(find.byKey(const Key('player_paused')), findsNothing);
  });

  testWidgets('skip advances and previous returns', (tester) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_skip')));
    await tester.pump();
    expect(find.text('Shoulder circles'), findsOneWidget);
    expect(find.text('Movement 2 of 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('player_previous')));
    await tester.pump();
    expect(find.text('Neck release'), findsOneWidget);
    expect(find.text('Movement 1 of 2'), findsOneWidget);
  });

  testWidgets('shows no bottom navigation, streak, points, or ads', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.textContaining('point'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('ad'), findsNothing);
  });

  testWidgets('renders in Arabic RTL without overflow', (tester) async {
    final container = buildRoutinePlayerContainer(language: AppLanguage.ar);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntilReady(tester);

    expect(find.text('تحرير الرقبة'), findsOneWidget);
    expect(find.text('الحركة 1 من 2'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing an unfinished routine asks for confirmation', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_close')));
    await _pumpUntil(tester, find.byKey(const Key('player_exit_dialog')));

    expect(find.byKey(const Key('player_exit_dialog')), findsOneWidget);
    expect(find.text('End routine?'), findsOneWidget);
    expect(find.byKey(const Key('player_exit_keep_going')), findsOneWidget);
    expect(find.byKey(const Key('player_exit_abandon')), findsOneWidget);

    await tester.tap(find.byKey(const Key('player_exit_keep_going')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('player_exit_dialog')), findsNothing);
    expect(find.byKey(const Key('player_movement_name')), findsOneWidget);
  });

  testWidgets('confirming exit abandons the routine and returns', (
    tester,
  ) async {
    final repository = FakeRoutineSessionRepository();
    final container = buildRoutinePlayerContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrapWithRouter(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_close')));
    await _pumpUntil(tester, find.byKey(const Key('player_exit_dialog')));
    await tester.tap(find.byKey(const Key('player_exit_abandon')));
    await _pumpUntil(tester, find.text('home'));

    // The player popped back to the parent route and the session was
    // terminalized as abandoned (not completed).
    expect(find.text('home'), findsOneWidget);
    expect(repository.saves, isNotEmpty);
    final abandonSave = repository.saves.last;
    expect(abandonSave.currentStepPosition, isNull);
    expect(abandonSave.steps.last.status, 'skipped');
  });

  testWidgets('restoring a session starts paused and user-controlled', (
    tester,
  ) async {
    final repository = FakeRoutineSessionRepository();
    repository.findByIdResult = RoutineSessionSnapshot(
      sessionId: 'session-1',
      routineId: 'rt-1',
      routineVersion: 1,
      startedAt: DateTime.utc(2026, 8, 29, 12),
      status: 'in_progress',
      currentStepPosition: 1,
      currentStepActiveSeconds: 2,
      steps: const [
        RoutineStepSnapshot(
          stepId: 'step-1',
          exerciseId: 'ex-1',
          position: 1,
          status: 'pending',
          targetDurationSeconds: 3,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
        RoutineStepSnapshot(
          stepId: 'step-2',
          exerciseId: 'ex-2',
          position: 2,
          status: 'pending',
          targetDurationSeconds: 5,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
      ],
    );
    final container = buildRoutinePlayerContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1', sessionId: 'session-1'),
      ),
    );
    await _pumpUntilReady(tester);

    expect(find.byKey(const Key('player_paused')), findsOneWidget);
    expect(find.text('0:01'), findsOneWidget); // 3s step, 2s already credited
  });

  testWidgets('an in-progress session surfaces a resume/abandon choice', (
    tester,
  ) async {
    final repository = FakeRoutineSessionRepository();
    repository.resumableResult = RoutineSessionSnapshot(
      sessionId: 'old-session',
      routineId: 'rt-1',
      routineVersion: 1,
      startedAt: DateTime.utc(2026, 8, 29, 12),
      status: 'in_progress',
      currentStepPosition: 1,
      currentStepActiveSeconds: 1,
      steps: const [
        RoutineStepSnapshot(
          stepId: 'step-1',
          exerciseId: 'ex-1',
          position: 1,
          status: 'pending',
          targetDurationSeconds: 3,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
        RoutineStepSnapshot(
          stepId: 'step-2',
          exerciseId: 'ex-2',
          position: 2,
          status: 'pending',
          targetDurationSeconds: 5,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
      ],
    );
    final container = buildRoutinePlayerContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntil(tester, find.byKey(const Key('player_conflict_title')));

    expect(find.byKey(const Key('player_conflict_title')), findsOneWidget);
    expect(find.byKey(const Key('player_conflict_resume')), findsOneWidget);
    expect(find.byKey(const Key('player_conflict_abandon')), findsOneWidget);
  });

  testWidgets('exit dialog renders in Arabic RTL without overflow', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer(language: AppLanguage.ar);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_close')));
    await _pumpUntil(tester, find.byKey(const Key('player_exit_dialog')));

    expect(find.text('إنهاء الروتين؟'), findsOneWidget);
    expect(find.byKey(const Key('player_exit_abandon')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skipping to the end shows the abandoned terminal state', (
    tester,
  ) async {
    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_skip')));
    await _pumpUntil(tester, find.byKey(const Key('player_finish')));
    await tester.tap(find.byKey(const Key('player_finish')));
    await _pumpUntil(tester, find.byKey(const Key('player_ended')));

    expect(find.byKey(const Key('player_ended')), findsOneWidget);
    expect(find.text('Routine ended'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('abandoned state renders in Arabic RTL', (tester) async {
    final container = buildRoutinePlayerContainer(language: AppLanguage.ar);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_skip')));
    await _pumpUntil(tester, find.byKey(const Key('player_finish')));
    await tester.tap(find.byKey(const Key('player_finish')));
    await _pumpUntil(tester, find.byKey(const Key('player_ended')));

    expect(find.text('انتهى الروتين'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('conflict choice renders in Arabic RTL', (tester) async {
    final repository = FakeRoutineSessionRepository();
    repository.resumableResult = RoutineSessionSnapshot(
      sessionId: 'old-session',
      routineId: 'rt-1',
      routineVersion: 1,
      startedAt: DateTime.utc(2026, 8, 29, 12),
      status: 'in_progress',
      currentStepPosition: 1,
      currentStepActiveSeconds: 1,
      steps: const [
        RoutineStepSnapshot(
          stepId: 'step-1',
          exerciseId: 'ex-1',
          position: 1,
          status: 'pending',
          targetDurationSeconds: 3,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
        RoutineStepSnapshot(
          stepId: 'step-2',
          exerciseId: 'ex-2',
          position: 2,
          status: 'pending',
          targetDurationSeconds: 5,
          activeDurationSeconds: 0,
          skipRequested: false,
        ),
      ],
    );
    final container = buildRoutinePlayerContainer(
      repository: repository,
      language: AppLanguage.ar,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('player_conflict_title')));

    expect(find.text('روتين غير مكتمل'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('exit dialog renders at 200% text scale on a compact screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = buildRoutinePlayerContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrapScaled(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);

    await tester.tap(find.byKey(const Key('player_close')));
    await _pumpUntil(tester, find.byKey(const Key('player_exit_dialog')));

    expect(find.byKey(const Key('player_exit_dialog')), findsOneWidget);
    expect(find.byKey(const Key('player_exit_abandon')), findsOneWidget);
    expect(find.text('End routine?'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The dialog title is announced as a semantic header.
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      ),
      findsWidgets,
    );
  });

  testWidgets('completed routine shows feedback choices and active minutes', (
    tester,
  ) async {
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    expect(find.byKey(const Key('feedback_question')), findsOneWidget);
    expect(find.text('How does your body feel now?'), findsOneWidget);
    expect(find.byKey(const Key('feedback_active_minutes')), findsOneWidget);
    expect(find.text('You moved for 1 minute'), findsOneWidget);
    expect(find.byKey(const Key('feedback_much_better')), findsOneWidget);
    expect(find.byKey(const Key('feedback_little_better')), findsOneWidget);
    expect(find.byKey(const Key('feedback_same')), findsOneWidget);
    expect(find.byKey(const Key('feedback_less_comfortable')), findsOneWidget);
    expect(find.byKey(const Key('feedback_skip')), findsOneWidget);
    // No points, streaks, or rewards before RAHA-070.
    expect(find.textContaining('point'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('less_comfortable shows approved copy and a restrained state', (
    tester,
  ) async {
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    await tester.tap(find.byKey(const Key('feedback_less_comfortable')));
    await _pumpUntil(tester, find.byKey(const Key('feedback_acknowledgement')));

    expect(
      find.text(
        'Thanks for sharing that. Please stop for today and choose a '
        'comfortable option next time.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('feedback_done')), findsOneWidget);
    expect(find.byKey(const Key('feedback_much_better')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip leaves without saving feedback', (tester) async {
    final ticker = FakePlaybackTicker();
    final feedback = FakeRoutineFeedbackRepository();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      feedbackRepository: feedback,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrapWithRouter(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    await tester.tap(find.byKey(const Key('feedback_skip')));
    await _pumpUntil(tester, find.text('home'));

    expect(find.text('home'), findsOneWidget);
    expect(feedback.saves, isEmpty);
  });

  testWidgets('save error shows retry and preserves the selected response', (
    tester,
  ) async {
    final ticker = FakePlaybackTicker();
    final feedback = FakeRoutineFeedbackRepository()..failSave = true;
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      feedbackRepository: feedback,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    await tester.tap(find.byKey(const Key('feedback_little_better')));
    await _pumpUntil(tester, find.byKey(const Key('feedback_save_error')));

    expect(find.byKey(const Key('feedback_retry')), findsOneWidget);
    expect(find.byKey(const Key('feedback_skip')), findsOneWidget);
    expect(feedback.saves, isEmpty);

    feedback.failSave = false;
    await tester.tap(find.byKey(const Key('feedback_retry')));
    await _pumpUntil(tester, find.byKey(const Key('feedback_acknowledgement')));

    expect(feedback.saves, hasLength(1));
    expect(feedback.saves.single.rating, FeedbackRating.littleBetter);
  });

  testWidgets('feedback renders in Arabic RTL', (tester) async {
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      language: AppLanguage.ar,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    expect(find.text('كيف يشعر جسمك الآن؟'), findsOneWidget);
    expect(find.byKey(const Key('feedback_less_comfortable')), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('less_comfortable shows the approved Arabic copy', (
    tester,
  ) async {
    final ticker = FakePlaybackTicker();
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      language: AppLanguage.ar,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(
        container,
        const RoutinePlayerScreen(routineId: 'rt-1'),
        locale: const Locale('ar'),
      ),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    await tester.tap(find.byKey(const Key('feedback_less_comfortable')));
    await _pumpUntil(tester, find.byKey(const Key('feedback_acknowledgement')));

    expect(
      find.text(
        'شكرًا لإخبارنا. توقّف لليوم واختر خيارًا مريحًا في المرة القادمة.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'feedback choices render at 200% text scale on a compact screen',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ticker = FakePlaybackTicker();
      final container = buildRoutinePlayerContainer(
        ticker: ticker,
        planForLocale: (locale) => minutePlan(locale: locale),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrapScaled(container, const RoutinePlayerScreen(routineId: 'rt-1')),
      );
      await _pumpUntilReady(tester);
      await _completeRoutine(tester, ticker);

      expect(find.byKey(const Key('feedback_question')), findsOneWidget);
      expect(
        find.byKey(const Key('feedback_less_comfortable')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a stored response is shown without re-writing or re-emitting', (
    tester,
  ) async {
    final ticker = FakePlaybackTicker();
    final feedback = FakeRoutineFeedbackRepository()
      ..findResult = FeedbackRating.lessComfortable;
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildRoutinePlayerContainer(
      ticker: ticker,
      feedbackRepository: feedback,
      analytics: analytics,
      planForLocale: (locale) => minutePlan(locale: locale),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, const RoutinePlayerScreen(routineId: 'rt-1')),
    );
    await _pumpUntilReady(tester);
    await _completeRoutine(tester, ticker);

    // A previously stored answer surfaces as the acknowledgment, not choices.
    await _pumpUntil(tester, find.byKey(const Key('feedback_acknowledgement')));
    expect(
      find.text(
        'Thanks for sharing that. Please stop for today and choose a '
        'comfortable option next time.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('feedback_question')), findsNothing);
    expect(feedback.saves, isEmpty);
    expect(
      analytics.recordedEvents.where((e) => e.name == 'feedback_submitted'),
      isEmpty,
    );
  });
}

Future<void> _completeRoutine(
  WidgetTester tester,
  FakePlaybackTicker ticker,
) async {
  for (var i = 0; i < 60; i++) {
    ticker.fireTick();
  }
  await _pumpUntil(tester, find.byKey(const Key('feedback_question')));
}

Future<void> _pumpUntilReady(WidgetTester tester) async {
  final ready = find.byKey(const Key('player_movement_name'));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (ready.evaluate().isNotEmpty) return;
  }
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
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

/// Wraps the player with a 200% text scaler for large-text/accessibility
/// coverage.
Widget _wrapScaled(
  ProviderContainer container,
  Widget child, {
  Locale? locale,
}) {
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2.0)),
        child: child!,
      ),
      home: child,
    ),
  );
}

/// Wraps the player in a minimal GoRouter with a parent route so the exit
/// confirmation's `context.pop()` can navigate back instead of throwing.
Widget _wrapWithRouter(ProviderContainer container, Widget child) {
  final router = GoRouter(
    initialLocation: '/player',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('home'))),
        routes: [GoRoute(path: 'player', builder: (context, state) => child)],
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    ),
  );
}
