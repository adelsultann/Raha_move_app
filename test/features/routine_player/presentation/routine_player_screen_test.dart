import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
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
}

Future<void> _pumpUntilReady(WidgetTester tester) async {
  final ready = find.byKey(const Key('player_movement_name'));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (ready.evaluate().isNotEmpty) return;
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
