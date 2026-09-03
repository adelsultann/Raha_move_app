import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/today/application/today_providers.dart';
import 'package:raha_move/features/today/domain/today_repository.dart';
import 'package:raha_move/features/today/presentation/today_screen.dart';

void main() {
  testWidgets('shows dominant check-in and local offline progress in English', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        _dashboard(authoritative: false, pendingAwards: 1),
        onStart: () => started = true,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('start_check_in')), findsOneWidget);
    expect(find.text('Showing your local progress'), findsOneWidget);
    expect(find.text('10 points pending confirmation'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start_check_in')));
    expect(started, isTrue);
    expect(find.bySemanticsLabel('Start today\'s check-in'), findsOneWidget);
  });

  testWidgets('refreshes mounted Today after an offline local completion', (
    tester,
  ) async {
    final updates = StreamController<TodayDashboard>();
    addTearDown(updates.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) => updates.stream),
        ],
        child: _app(
          const Locale('en'),
          const TodayScreen(
            onStartCheckIn: _nothing,
            onResume: _resumeNothing,
            onRepeat: _repeatNothing,
          ),
        ),
      ),
    );
    updates.add(_dashboard(movementDays: 0, authoritative: false));
    await tester.pump();
    expect(find.text('0 of 3 movement days this week'), findsOneWidget);

    // This is the projection immediately after an offline terminal session
    // write, before server confirmation.
    updates.add(
      _dashboard(
        movementDays: 1,
        authoritative: false,
        pendingAwards: 1,
        recent: _recent(),
      ),
    );
    await tester.pump();
    expect(find.text('1 of 3 movement days this week'), findsOneWidget);
    expect(find.text('Showing your local progress'), findsOneWidget);
    expect(find.text('Desk reset'), findsOneWidget);
  });

  testWidgets('renders Arabic RTL and stays usable at compact 200% scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _wrap(const Locale('ar'), _dashboard(), textScale: 2),
    );
    await tester.pump();

    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    await tester.ensureVisible(find.byKey(const Key('start_check_in')));
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (locale: const Locale('en'), size: const Size(360, 640), action: 'Resume'),
    (locale: const Locale('ar'), size: const Size(360, 640), action: 'متابعة'),
    (locale: const Locale('en'), size: const Size(390, 844), action: 'Resume'),
    (locale: const Locale('ar'), size: const Size(390, 844), action: 'متابعة'),
  ]) {
    testWidgets(
      'keeps Today actions ordered and accessible at 200% ${scenario.locale.languageCode} ${scenario.size}',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var checkInTaps = 0;
        await tester.pumpWidget(
          _wrap(
            scenario.locale,
            _dashboard(resumable: _resumable(name: 'Desk reset')),
            onStart: () => checkInTaps++,
            textScale: 2,
          ),
        );
        await tester.pump();

        final checkIn = find.byKey(const Key('start_check_in'));
        final resume = find.byKey(const Key('today_resume'));
        expect(checkIn, findsOneWidget);
        await tester.ensureVisible(checkIn);
        await tester.tap(checkIn);
        expect(checkInTaps, 1);

        await tester.ensureVisible(resume);
        final semantics = tester.getSemantics(resume);
        expect(
          semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(find.bySemanticsLabel(scenario.action), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('resumable session takes precedence and passes its session id', (
    tester,
  ) async {
    String? routineId;
    String? sessionId;
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        _dashboard(
          resumable: _resumable(name: 'Desk reset'),
          recent: _recent(),
        ),
        onResume: (routine, session) {
          routineId = routine;
          sessionId = session;
        },
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('today_resume')), findsOneWidget);
    expect(find.byKey(const Key('today_repeat')), findsNothing);
    expect(find.text('Resume Desk reset when you are ready.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today_resume')));
    expect(routineId, 'routine-1');
    expect(sessionId, 'session-1');
  });

  testWidgets('localizes the resume routine name and has a calm fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Locale('ar'),
        _dashboard(resumable: _resumable(name: 'استراحة المكتب')),
      ),
    );
    await tester.pump();
    expect(
      find.text('تابع استراحة المكتب عندما تكون مستعدًا.'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      _wrap(const Locale('en'), _dashboard(resumable: _resumable())),
    );
    await tester.pump();
    expect(
      find.text('Your unfinished routine is ready when you are.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a recent completed routine and repeats it', (
    tester,
  ) async {
    String? repeated;
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        _dashboard(recent: _recent()),
        onRepeat: (routine) => repeated = routine,
      ),
    );
    await tester.pump();
    expect(find.text('Desk reset'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today_repeat')));
    expect(repeated, 'routine-1');
  });

  testWidgets('has loading, new-user, and recoverable retry states', (
    tester,
  ) async {
    final loading = Completer<TodayDashboard>();
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) {
            calls++;
            return calls == 1
                ? Stream.fromFuture(loading.future)
                : Stream.value(_dashboard());
          }),
        ],
        child: _app(
          const Locale('en'),
          const TodayScreen(
            onStartCheckIn: _nothing,
            onResume: _resumeNothing,
            onRepeat: _repeatNothing,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('today_loading')), findsOneWidget);
    loading.completeError(StateError('local read failed'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('today_retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('today_retry')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('today_new_user')), findsOneWidget);
  });
}

TodayDashboard _dashboard({
  bool authoritative = true,
  int pendingAwards = 0,
  int movementDays = 2,
  TodayResumableRoutine? resumable,
  TodayCompletedRoutine? recent,
}) => TodayDashboard(
  weeklyGoal: WeeklyGoalProgress(
    weekStart: const MovementDate(2026, 9, 7),
    goalDays: 3,
    movementDays: movementDays,
    pendingPointAwards: pendingAwards,
    isAuthoritative: authoritative,
  ),
  resumableRoutine: resumable,
  latestCompletedRoutine: recent,
);

TodayResumableRoutine _resumable({String? name}) => TodayResumableRoutine(
  sessionId: 'session-1',
  routineId: 'routine-1',
  name: name,
);

TodayCompletedRoutine _recent() => TodayCompletedRoutine(
  routineId: 'routine-1',
  sessionId: 'completed-session-1',
  name: 'Desk reset',
  completedAt: DateTime(2026, 9, 8),
);

Widget _wrap(
  Locale locale,
  TodayDashboard dashboard, {
  VoidCallback? onStart,
  void Function(String, String)? onResume,
  void Function(String)? onRepeat,
  double textScale = 1,
}) => ProviderScope(
  key: ValueKey('${locale.languageCode}-${dashboard.resumableRoutine?.name}'),
  overrides: [
    todayDashboardProvider.overrideWith((ref) => Stream.value(dashboard)),
  ],
  child: _app(
    locale,
    TodayScreen(
      onStartCheckIn: onStart ?? _nothing,
      onResume: onResume ?? _resumeNothing,
      onRepeat: onRepeat ?? _repeatNothing,
    ),
    textScale: textScale,
  ),
);

Widget _app(Locale locale, Widget child, {double textScale = 1}) => MaterialApp(
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
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: child,
);

void _nothing() {}
void _resumeNothing(String routineId, String sessionId) {}
void _repeatNothing(String _) {}
