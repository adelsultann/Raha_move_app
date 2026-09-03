import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/theme/app_theme.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/today/application/today_providers.dart';
import 'package:raha_move/features/today/domain/today_repository.dart';
import 'package:raha_move/features/today/presentation/today_screen.dart';

import 'golden_font_loader.dart';

void main() {
  setUpAll(GoldenFontLoader.load);

  for (final scenario in [
    (
      name: 'en_standard',
      locale: const Locale('en'),
      size: const Size(390, 844),
      scale: 1.0,
    ),
    (
      name: 'ar_standard',
      locale: const Locale('ar'),
      size: const Size(390, 844),
      scale: 1.0,
    ),
    (
      name: 'en_standard_200',
      locale: const Locale('en'),
      size: const Size(390, 844),
      scale: 2.0,
    ),
    (
      name: 'ar_standard_200',
      locale: const Locale('ar'),
      size: const Size(390, 844),
      scale: 2.0,
    ),
    (
      name: 'en_compact_200',
      locale: const Locale('en'),
      size: const Size(360, 640),
      scale: 2.0,
    ),
    (
      name: 'ar_compact_200',
      locale: const Locale('ar'),
      size: const Size(360, 640),
      scale: 2.0,
    ),
  ]) {
    testWidgets('Today ${scenario.name}', (tester) async {
      await tester.binding.setSurfaceSize(scenario.size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_goldenApp(scenario.locale, scenario.scale));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_${scenario.name}.png'),
      );
    });
  }
}

Widget _goldenApp(Locale locale, double textScale) => ProviderScope(
  overrides: [
    todayDashboardProvider.overrideWith(
      (ref) => Stream.value(
        TodayDashboard(
          weeklyGoal: const WeeklyGoalProgress(
            weekStart: MovementDate(2026, 9, 7),
            goalDays: 3,
            movementDays: 2,
            pendingPointAwards: 1,
            isAuthoritative: false,
          ),
          resumableRoutine: TodayResumableRoutine(
            routineId: 'routine-1',
            sessionId: 'session-1',
            name: locale.languageCode == 'ar' ? 'استراحة المكتب' : 'Desk reset',
          ),
          latestCompletedRoutine: null,
        ),
      ),
    ),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _goldenTheme(),
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
    home: const TodayScreen(
      onStartCheckIn: _nothing,
      onResume: _resumeNothing,
      onRepeat: _repeatNothing,
    ),
  ),
);

void _nothing() {}
void _resumeNothing(String routineId, String sessionId) {}
void _repeatNothing(String routineId) {}

ThemeData _goldenTheme() {
  final theme = AppTheme.light();
  return theme.copyWith(
    textTheme: _withGoldenFonts(theme.textTheme),
    primaryTextTheme: _withGoldenFonts(theme.primaryTextTheme),
  );
}

TextTheme _withGoldenFonts(TextTheme textTheme) => textTheme.copyWith(
  displayLarge: _withGoldenFontsStyle(textTheme.displayLarge),
  displayMedium: _withGoldenFontsStyle(textTheme.displayMedium),
  displaySmall: _withGoldenFontsStyle(textTheme.displaySmall),
  headlineLarge: _withGoldenFontsStyle(textTheme.headlineLarge),
  headlineMedium: _withGoldenFontsStyle(textTheme.headlineMedium),
  headlineSmall: _withGoldenFontsStyle(textTheme.headlineSmall),
  titleLarge: _withGoldenFontsStyle(textTheme.titleLarge),
  titleMedium: _withGoldenFontsStyle(textTheme.titleMedium),
  titleSmall: _withGoldenFontsStyle(textTheme.titleSmall),
  bodyLarge: _withGoldenFontsStyle(textTheme.bodyLarge),
  bodyMedium: _withGoldenFontsStyle(textTheme.bodyMedium),
  bodySmall: _withGoldenFontsStyle(textTheme.bodySmall),
  labelLarge: _withGoldenFontsStyle(textTheme.labelLarge),
  labelMedium: _withGoldenFontsStyle(textTheme.labelMedium),
  labelSmall: _withGoldenFontsStyle(textTheme.labelSmall),
);

TextStyle? _withGoldenFontsStyle(TextStyle? style) => style?.copyWith(
  fontFamily: GoldenFontLoader.latinFamily,
  fontFamilyFallback: const [GoldenFontLoader.arabicFamily],
);
