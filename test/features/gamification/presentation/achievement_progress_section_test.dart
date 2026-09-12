import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/gamification/application/gamification_providers.dart';
import 'package:raha_move/features/gamification/domain/achievement_progress.dart';
import 'package:raha_move/features/gamification/presentation/achievement_progress_section.dart';

void main() {
  testWidgets('shows a localized locked badge in Arabic RTL at compact scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const Locale('ar'), earned: false, scale: 2));
    await tester.pump();

    expect(find.text('خطوتك الأولى'), findsOneWidget);
    expect(find.text('للاستكشاف'), findsOneWidget);
    expect(
      find.bySemanticsLabel('محطة للاستكشاف: خطوتك الأولى'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a localized earned badge in English LTR', (tester) async {
    await tester.pumpWidget(_app(const Locale('en'), earned: true));
    await tester.pump();

    expect(find.text('First Step'), findsOneWidget);
    expect(find.text('Earned'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Earned milestone: First Step'),
      findsOneWidget,
    );
  });
}

Widget _app(Locale locale, {required bool earned, double scale = 1}) =>
    ProviderScope(
      overrides: [
        achievementProgressProvider.overrideWith(
          (ref) => Future.value([_achievement(earned: earned)]),
        ),
      ],
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
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(padding: const EdgeInsets.all(16), child: child),
              ),
            ),
          ),
        ),
        home: const AchievementProgressSection(),
      ),
    );

AchievementProgress _achievement({required bool earned}) => AchievementProgress(
  key: 'first_step',
  category: 'getting_started',
  criteriaVersion: 1,
  ruleVersion: 'achievement_sessions_v1',
  iconKey: 'first_step',
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
  earnedAt: earned ? DateTime.utc(2026, 9, 12) : null,
  sourceId: earned ? 'session-1' : null,
  earnedCriteriaVersion: earned ? 1 : null,
);
