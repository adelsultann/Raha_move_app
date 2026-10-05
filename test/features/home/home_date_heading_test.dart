import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/home/widgets/home_date_heading.dart';

void main() {
  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('date heading is localized and right aligned in $locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: HomeDateHeading(date: DateTime(2026, 10, 5)),
            ),
          ),
        ),
      );
      final day = find.byKey(const Key('home_day'));
      final date = find.byKey(const Key('home_date'));
      expect(
        tester.widget<Text>(day).data,
        locale.languageCode == 'en'
            ? 'Monday'
            : '\u0627\u0644\u0627\u062b\u0646\u064a\u0646',
      );
      if (locale.languageCode == 'en') {
        expect(tester.widget<Text>(date).data, '5 October');
      } else {
        expect(
          tester.widget<Text>(date).data,
          contains('\u0623\u0643\u062a\u0648\u0628\u0631'),
        );
      }
      expect(tester.getBottomRight(day).dx, tester.getBottomRight(date).dx);
      expect(
        tester.getTopLeft(day).dy,
        greaterThan(tester.getBottomLeft(date).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
