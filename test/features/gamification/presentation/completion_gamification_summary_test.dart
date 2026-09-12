import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/application/gamification_providers.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/gamification/domain/streak_progress.dart';
import 'package:raha_move/features/gamification/domain/achievement_progress.dart';
import 'package:raha_move/features/gamification/presentation/completion_gamification_summary.dart';

void main() {
  testWidgets('shows confirmed and offline-pending progress in English LTR', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        Future.value(_progress(confirmedPoints: 20, pendingAwards: 1)),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('gamification_weekly_goal')), findsOneWidget);
    expect(find.text('2 of 3 movement days this week'), findsOneWidget);
    expect(find.text('20 movement points confirmed'), findsOneWidget);
    expect(find.text('10 points pending confirmation'), findsOneWidget);
    expect(find.text('2-day movement streak'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('supports Arabic RTL at 200 percent compact scaling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _wrap(
        const Locale('ar'),
        Future.value(_progress(pendingAwards: 1)),
        textScale: 2,
      ),
    );
    await tester.pump();
    expect(find.text('2 من 3 أيام حركة هذا الأسبوع'), findsOneWidget);
    expect(find.text('10 نقاط بانتظار التأكيد'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows only badges earned by this completion', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        Future.value(_progress()),
        achievements: Future.value([
          _achievement(key: 'first_step', sourceId: 'session-1'),
          _achievement(key: 'gentle_habit_7', sourceId: 'older-session'),
        ]),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('achievement_earned_first_step')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('achievement_earned_gentle_habit_7')),
      findsNothing,
    );
  });

  testWidgets('has loading, error, and retry states', (tester) async {
    final completer = Completer<WeeklyGoalProgress>();
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weeklyGoalProgressProvider.overrideWith((ref) {
            attempts++;
            return attempts == 1 ? completer.future : Future.value(_progress());
          }),
          streakProgressProvider.overrideWith((ref) => Future.value(_streak())),
          achievementProgressProvider.overrideWith(
            (ref) => Future.value(const []),
          ),
        ],
        child: _app(const Locale('en')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.completeError(StateError('offline'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('gamification_summary_error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('gamification_summary_retry')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('gamification_weekly_goal')), findsOneWidget);
  });

  testWidgets('supports English LTR at 200 percent compact scaling', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _wrap(
        const Locale('en'),
        Future.value(_progress(confirmedPoints: 10, pendingAwards: 1)),
        textScale: 2,
      ),
    );
    await tester.pump();
    expect(find.text('2 of 3 movement days this week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(
  Locale locale,
  Future<WeeklyGoalProgress> value, {
  double textScale = 1,
  Future<List<AchievementProgress>>? achievements,
}) => ProviderScope(
  overrides: [
    weeklyGoalProgressProvider.overrideWith((ref) => value),
    streakProgressProvider.overrideWith((ref) => Future.value(_streak())),
    achievementProgressProvider.overrideWith(
      (ref) => achievements ?? Future.value(const []),
    ),
  ],
  child: _app(locale, textScale: textScale),
);

Widget _app(Locale locale, {double textScale = 1}) => MaterialApp(
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
    child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  ),
  home: const CompletionGamificationSummary(sessionId: 'session-1'),
);

WeeklyGoalProgress _progress({int? confirmedPoints, int pendingAwards = 0}) =>
    WeeklyGoalProgress(
      weekStart: const MovementDate(2026, 9, 7),
      goalDays: 3,
      movementDays: 2,
      pendingPointAwards: pendingAwards,
      isAuthoritative: pendingAwards == 0,
      confirmedPoints: confirmedPoints,
    );

StreakProgress _streak() => const StreakProgress(
  currentDays: 2,
  longestDays: 2,
  ruleVersion: 'streak_v1',
  isAuthoritative: true,
);

AchievementProgress _achievement({
  required String key,
  required String sourceId,
}) => AchievementProgress(
  key: key,
  category: 'getting_started',
  criteriaVersion: 1,
  ruleVersion: 'achievement_sessions_v1',
  iconKey: key == 'first_step' ? 'first_step' : 'gentle_habit',
  status: 'published',
  translations: const {
    'en': AchievementTranslation(
      title: 'First Step',
      description: 'You completed your first routine.',
    ),
    'ar': AchievementTranslation(
      title: 'خطوتك الأولى',
      description: 'أكملت روتينك الأول.',
    ),
  },
  earnedAt: DateTime.utc(2026, 9, 12),
  sourceId: sourceId,
  earnedCriteriaVersion: 1,
);
