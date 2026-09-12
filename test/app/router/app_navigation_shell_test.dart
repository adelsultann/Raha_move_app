import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_navigation_shell.dart';

void main() {
  Future<void> pumpNavigationBar(
    WidgetTester tester, {
    required Locale locale,
    required ValueChanged<int> onDestinationSelected,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          bottomNavigationBar: RahaNavigationBar(
            currentIndex: 0,
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the four localized English destinations', (tester) async {
    await pumpNavigationBar(
      tester,
      locale: const Locale('en'),
      onDestinationSelected: (_) {},
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('mirrors and labels destinations in Arabic', (tester) async {
    await pumpNavigationBar(
      tester,
      locale: const Locale('ar'),
      onDestinationSelected: (_) {},
    );

    expect(
      Directionality.of(tester.element(find.byType(NavigationBar))),
      TextDirection.rtl,
    );
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('استكشف'), findsOneWidget);
    expect(find.text('تقدّمك'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });

  testWidgets('announces and selects the tapped destination', (tester) async {
    var selectedIndex = -1;
    await pumpNavigationBar(
      tester,
      locale: const Locale('en'),
      onDestinationSelected: (index) => selectedIndex = index,
    );

    await tester.tap(find.text('Progress'));

    expect(selectedIndex, 2);
    expect(find.bySemanticsLabel(RegExp('Progress')), findsOneWidget);
  });
}
