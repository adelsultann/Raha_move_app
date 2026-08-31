import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/check_in/application/check_in_providers.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/check_in/domain/check_in_repository.dart';

import '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore;

export '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore;

/// In-memory check-in persistence for tests.
final class FakeCheckInRepository implements CheckInRepository {
  String? savedFor;
  String? savedId;
  DateTime? savedStartedAt;
  CheckInAnswers? savedAnswers;
  int saveCount = 0;

  /// When non-null, [save] throws this so tests can exercise the failure path.
  Object? saveError;

  @override
  Future<void> save({
    required String userId,
    required String checkInId,
    required DateTime startedAt,
    required CheckInAnswers answers,
  }) async {
    final error = saveError;
    if (error != null) throw error;
    saveCount += 1;
    savedFor = userId;
    savedId = checkInId;
    savedStartedAt = startedAt;
    savedAnswers = answers;
  }
}

/// Builds a container wired with offline auth, a stable guest identity, the
/// given check-in repository, and an enabled in-memory analytics sink.
ProviderContainer buildCheckInContainer({
  FakeCheckInRepository? repository,
  InMemoryAnalyticsService? analytics,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      guestIdentityStoreProvider.overrideWithValue(FakeGuestIdentityStore()),
      checkInRepositoryProvider.overrideWithValue(
        repository ?? FakeCheckInRepository(),
      ),
      analyticsServiceProvider.overrideWithValue(
        analytics ?? InMemoryAnalyticsService(enabled: true),
      ),
    ],
  );
}
