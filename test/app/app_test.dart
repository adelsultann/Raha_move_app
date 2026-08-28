import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/app.dart';
import 'package:raha_move/features/foundation/application/foundation_status_provider.dart';

void main() {
  testWidgets('renders the localized foundation screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RahaMoveApp()));

    expect(
      find.text('Your calm movement companion is getting ready.'),
      findsOneWidget,
    );
  });

  test('generated provider exposes the build environment', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(foundationStatusProvider).isReady, isTrue);
  });

  testWidgets('renders Arabic with right-to-left directionality', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: RahaMoveApp(locale: Locale('ar'))),
    );

    expect(find.text('رفيقك الهادئ للحركة يستعد للانطلاق.'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });
}
