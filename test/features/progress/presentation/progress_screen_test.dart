import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/progress/application/progress_providers.dart';
import 'package:raha_move/features/progress/domain/progress_summary.dart';
import 'package:raha_move/features/progress/presentation/progress_screen.dart';

void main() {
  const week = MovementDate(2026, 9, 7);

  testWidgets(
    'shows localized summary and provisional local state in English',
    (tester) async {
      await tester.pumpWidget(
        _app(const Locale('en'), _summary(provisional: true)),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Your movement this week'), findsOneWidget);
      expect(find.text('2 of 3 movement days'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Neck'), findsOneWidget);
      expect(find.text('Recent completed routines'), findsOneWidget);
    },
  );

  testWidgets('renders Arabic RTL at compact 200% text scale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const Locale('ar'), _summary(), textScale: 2));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('حركتك هذا الأسبوع'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (locale: const Locale('en'), size: const Size(360, 640), scale: 2.0),
    (locale: const Locale('ar'), size: const Size(360, 640), scale: 2.0),
    (locale: const Locale('en'), size: const Size(390, 844), scale: 1.0),
    (locale: const Locale('ar'), size: const Size(390, 844), scale: 1.0),
  ]) {
    testWidgets(
      'keeps period navigation accessible in ${scenario.locale.languageCode} ${scenario.size}',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          _app(scenario.locale, _summary(), textScale: scenario.scale),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const Key('progress_previous_week')), findsOneWidget);
        expect(find.byKey(const Key('progress_next_week')), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            scenario.locale.languageCode == 'ar'
                ? 'الأسبوع السابق'
                : 'Previous week',
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            scenario.locale.languageCode == 'ar'
                ? 'الأسبوع التالي'
                : 'Next week',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('formats history dates through each active locale', (
    tester,
  ) async {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      await tester.pumpWidget(
        _material(
          locale,
          Builder(
            builder: (context) => Text(
              formatProgressHistoryDate(
                context,
                const MovementDate(2026, 9, 8),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('2026-09-08'), findsNothing);
      expect(find.byType(Text), findsOneWidget);
    }
  });

  testWidgets('has loading, empty, error, and retry states', (tester) async {
    final controller = StreamController<ProgressSummary>();
    addTearDown(controller.close);
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCurrentProgressWeekProvider.overrideWith(
            (ref) => Stream.value(week),
          ),
          progressSummaryProvider(week).overrideWith((ref) {
            attempts++;
            return attempts == 1
                ? controller.stream
                : Stream.value(_summary(empty: true));
          }),
        ],
        child: _material(const Locale('en'), const ProgressScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('progress_loading')), findsOneWidget);
    controller.addError(StateError('local read failed'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('progress_retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('progress_retry')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Your movement history will appear here'), findsOneWidget);
  });
}

ProgressSummary _summary({bool provisional = false, bool empty = false}) =>
    ProgressSummary(
      weekStart: const MovementDate(2026, 9, 7),
      weeklyGoalDays: 3,
      movementDays: empty ? 0 : 2,
      verifiedActiveSeconds: empty ? 0 : 600,
      completedRoutines: empty ? 0 : 2,
      hasProvisionalProgress: provisional,
      bodyAreas: empty
          ? const []
          : const [ProgressBodyArea(key: 'neck', label: 'Neck')],
      feedback: const FeedbackTrend(
        muchBetter: 1,
        littleBetter: 1,
        same: 0,
        lessComfortable: 0,
      ),
      recentHistory: empty
          ? const []
          : const [
              CompletedRoutineHistory(
                sessionId: 'session-1',
                routineName: 'Desk reset',
                completedDay: MovementDate(2026, 9, 8),
                verifiedActiveSeconds: 300,
                isProvisional: false,
              ),
            ],
    );

Widget _app(Locale locale, ProgressSummary summary, {double textScale = 1}) =>
    ProviderScope(
      overrides: [
        localCurrentProgressWeekProvider.overrideWith(
          (ref) => Stream.value(const MovementDate(2026, 9, 7)),
        ),
        progressSummaryProvider(const MovementDate(2026, 9, 7))
            .overrideWith((ref) => Stream.value(summary)),
      ],
      child: _material(locale, const ProgressScreen(), textScale: textScale),
    );

Widget _material(Locale locale, Widget child, {double textScale = 1}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: widget!,
      ),
      home: child,
    );
