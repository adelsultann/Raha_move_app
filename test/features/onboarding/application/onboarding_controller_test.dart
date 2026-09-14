import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/onboarding/application/onboarding_controller.dart';
import 'package:raha_move/features/onboarding/application/onboarding_providers.dart';

import '../support/onboarding_test_harness.dart';

void main() {
  test('build reports onboarding not complete for a fresh guest', () async {
    final container = buildOnboardingContainer();
    addTearDown(container.dispose);

    final completed = await container.read(onboardingControllerProvider.future);

    expect(completed, isFalse);
  });

  test('build reports complete when onboarding was already finished', () async {
    final repository = FakeOnboardingRepository()..completed = true;
    final container = buildOnboardingContainer(repository: repository);
    addTearDown(container.dispose);

    final completed = await container.read(onboardingControllerProvider.future);

    expect(completed, isTrue);
  });

  test('authenticated users bypass onboarding after sign-in', () async {
    final repository = FakeOnboardingRepository()
      ..readError = StateError('authenticated users should not be queried');
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
        onboardingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final completed = await container.read(onboardingControllerProvider.future);

    expect(completed, isTrue);
  });

  test(
    'complete persists, flips state, and records a privacy-safe event',
    () async {
      final repository = FakeOnboardingRepository();
      final analytics = InMemoryAnalyticsService(enabled: true);
      final container = buildOnboardingContainer(
        repository: repository,
        analytics: analytics,
      );
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      await container.read(onboardingControllerProvider.notifier).complete();

      expect(container.read(onboardingControllerProvider).value, isTrue);
      expect(repository.completedFor, 'guest-1');
      expect(analytics.recordedEvents, hasLength(1));
      expect(
        analytics.recordedEvents.single.name,
        AnalyticsEventName.onboardingCompleted,
      );
      expect(analytics.recordedEvents.single.properties, isEmpty);
    },
  );
}

final class _AuthenticatedAuthController extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    activeUserId: 'account-1',
    status: AuthStatus.authenticated,
  );
}
