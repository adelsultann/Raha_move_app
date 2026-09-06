import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/progress/application/progress_providers.dart';
import 'package:raha_move/features/progress/domain/progress_summary.dart';
import 'package:raha_move/features/progress/presentation/progress_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('keeps one offline completion visible after reconciliation', (
    tester,
  ) async {
    const week = MovementDate(2026, 9, 7);
    final summaries = StreamController<ProgressSummary>();
    addTearDown(summaries.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCurrentProgressWeekProvider.overrideWith(
            (ref) => Stream.value(week),
          ),
          progressSummaryProvider(week).overrideWith((ref) => summaries.stream),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ProgressScreen(),
        ),
      ),
    );

    summaries.add(_summary(provisional: true));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Active minutes (saved locally)'), findsOneWidget);
    expect(find.textContaining('saved on this device'), findsOneWidget);

    summaries.add(_summary(provisional: false));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Verified active minutes'), findsOneWidget);
    expect(find.textContaining('saved on this device'), findsNothing);
  });

  testWidgets('renders the reconciled history in Arabic RTL', (tester) async {
    const week = MovementDate(2026, 9, 7);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCurrentProgressWeekProvider.overrideWith(
            (ref) => Stream.value(week),
          ),
          progressSummaryProvider(
            week,
          ).overrideWith((ref) => Stream.value(_summary(provisional: false))),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ProgressScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('حركتك هذا الأسبوع'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });
}

ProgressSummary _summary({required bool provisional}) => ProgressSummary(
  weekStart: const MovementDate(2026, 9, 7),
  weeklyGoalDays: 3,
  movementDays: 1,
  verifiedActiveSeconds: 120,
  completedRoutines: 1,
  hasProvisionalProgress: provisional,
  bodyAreas: const [ProgressBodyArea(key: 'neck', label: 'Neck')],
  feedback: const FeedbackTrend(
    muchBetter: 1,
    littleBetter: 0,
    same: 0,
    lessComfortable: 0,
  ),
  recentHistory: const [
    CompletedRoutineHistory(
      sessionId: 'offline-session',
      routineName: 'Desk reset',
      completedDay: MovementDate(2026, 9, 8),
      verifiedActiveSeconds: 120,
      isProvisional: true,
    ),
  ],
);
