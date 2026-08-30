import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/app.dart';
import 'package:raha_move/features/foundation/application/foundation_status_provider.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';

import '../features/onboarding/support/onboarding_test_harness.dart';

void main() {
  testWidgets('renders the localized foundation screen in English', (
    tester,
  ) async {
    final container = buildOnboardingContainer(
      repository: FakeOnboardingRepository()..language = AppLanguage.en,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RahaMoveApp(),
      ),
    );
    await tester.pumpAndSettle();

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
    final container = buildOnboardingContainer(
      repository: FakeOnboardingRepository()..language = AppLanguage.ar,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RahaMoveApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('رفيقك الهادئ للحركة يستعد للانطلاق.'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });
}
