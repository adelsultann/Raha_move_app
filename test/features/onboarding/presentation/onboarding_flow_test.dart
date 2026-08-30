import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/onboarding/presentation/onboarding_gate.dart';

import '../support/onboarding_test_harness.dart';

void main() {
  testWidgets('presents Arabic and English with equal prominence', (
    tester,
  ) async {
    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language_arabic')), findsOneWidget);
    expect(find.byKey(const Key('language_english')), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Welcome to Raha Move'), findsOneWidget);
    expect(find.text('مرحباً بك في راحة موف'), findsOneWidget);
  });

  testWidgets('selecting Arabic applies RTL and shows Arabic onboarding', (
    tester,
  ) async {
    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language_arabic')));
    await tester.pumpAndSettle();

    expect(find.text('روتين مختار لك'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('selecting English applies LTR and shows English onboarding', (
    tester,
  ) async {
    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language_english')));
    await tester.pumpAndSettle();

    expect(find.text('A routine chosen for you'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('onboarding has three concise pages and finishes as guest', (
    tester,
  ) async {
    final repository = FakeOnboardingRepository();
    final analytics = InMemoryAnalyticsService(enabled: true);
    final container = buildOnboardingContainer(
      repository: repository,
      analytics: analytics,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language_english')));
    await tester.pumpAndSettle();

    // Page 1 -> Page 2 -> Page 3.
    expect(find.byKey(const Key('onboarding_next')), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();

    expect(find.text('Build a comfortable habit'), findsOneWidget);
    expect(find.byKey(const Key('onboarding_get_started')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding_get_started')));
    await tester.pumpAndSettle();

    // Completes as a guest and reaches the app without registration.
    expect(find.text('APP_READY'), findsOneWidget);
    expect(repository.completedFor, 'guest-1');
    expect(
      analytics.recordedEvents.map((e) => e.name),
      contains(AnalyticsEventName.onboardingCompleted),
    );
  });

  testWidgets('completed onboarding goes straight to the app', (tester) async {
    final repository = FakeOnboardingRepository()..completed = true;
    final container = buildOnboardingContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('APP_READY'), findsOneWidget);
    expect(find.byKey(const Key('language_arabic')), findsNothing);
  });

  testWidgets('onboarding remains usable at 200% text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language_arabic')), findsOneWidget);
    expect(find.byKey(const Key('language_english')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language selection fits a compact screen without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language_arabic')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a loading state until onboarding state resolves', (
    tester,
  ) async {
    final repository = FakeOnboardingRepository();
    final gate = Completer<void>();
    repository.readGate = gate.future;

    final container = buildOnboardingContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language_arabic')), findsOneWidget);
  });

  testWidgets('shows a recoverable error and recovers on retry', (
    tester,
  ) async {
    final repository = FakeOnboardingRepository()
      ..readError = StateError('boom');
    final container = buildOnboardingContainer(repository: repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_retry')), findsOneWidget);

    repository.readError = null;
    await tester.tap(find.byKey(const Key('onboarding_retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language_arabic')), findsOneWidget);
    expect(find.byKey(const Key('onboarding_retry')), findsNothing);
  });

  testWidgets('English onboarding pages stay usable at 200% text scale', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const OnboardingGate(child: _App()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('language_english')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_get_started')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'English onboarding pages fit a compact screen without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = buildOnboardingContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OnboardingGate(child: _App()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('language_english')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_get_started')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: Text('APP_READY')));
}
