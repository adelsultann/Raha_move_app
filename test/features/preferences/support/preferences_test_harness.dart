import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/preferences/application/preferences_providers.dart';

import '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakePreferencesRepository;

export '../../onboarding/support/onboarding_test_harness.dart'
    show FakePreferencesRepository;

/// Builds a container wired with offline auth, a stable guest identity, the
/// given preferences repository, and an enabled in-memory analytics sink.
ProviderContainer buildPreferencesContainer({
  FakePreferencesRepository? repository,
  InMemoryAnalyticsService? analytics,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      guestIdentityStoreProvider.overrideWithValue(FakeGuestIdentityStore()),
      preferencesRepositoryProvider.overrideWithValue(
        repository ?? FakePreferencesRepository(),
      ),
      analyticsServiceProvider.overrideWithValue(
        analytics ?? InMemoryAnalyticsService(enabled: true),
      ),
    ],
  );
}
