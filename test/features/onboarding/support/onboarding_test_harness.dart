import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/authentication/domain/auth_account.dart';
import 'package:raha_move/features/authentication/domain/auth_failure.dart';
import 'package:raha_move/features/authentication/domain/auth_repository.dart';
import 'package:raha_move/features/authentication/domain/guest_identity_store.dart';
import 'package:raha_move/features/onboarding/application/onboarding_providers.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/onboarding/domain/onboarding_repository.dart';

/// In-memory onboarding persistence for tests.
final class FakeOnboardingRepository implements OnboardingRepository {
  AppLanguage language = AppLanguage.ar;
  bool completed = false;
  String? completedFor;
  String? languageSavedFor;

  /// When non-null, reads await this before returning, so tests can observe the
  /// loading state.
  Future<void>? readGate;

  /// When non-null, reads throw this, so tests can observe the error state.
  Object? readError;

  Future<void> _beforeRead() async {
    final gate = readGate;
    if (gate != null) await gate;
    final error = readError;
    if (error != null) throw error;
  }

  @override
  Future<AppLanguage> readPreferredLanguage(String userId) async {
    await _beforeRead();
    return language;
  }

  @override
  Future<bool> isOnboardingComplete(String userId) async {
    await _beforeRead();
    return completed;
  }

  @override
  Future<void> savePreferredLanguage(
    String userId,
    AppLanguage language,
  ) async {
    this.language = language;
    languageSavedFor = userId;
  }

  @override
  Future<void> markOnboardingComplete(String userId) async {
    completed = true;
    completedFor = userId;
  }
}

final class FakeAuthRepository implements AuthRepository {
  @override
  bool get isConfigured => false;

  @override
  Stream<AuthAccount?> watchAccount() => Stream<AuthAccount?>.value(null);

  @override
  Future<AuthAccount?> restoreSession() async => null;

  @override
  Future<AuthAccount> signInAnonymously() async =>
      throw const AuthFailureException(AuthFailure.networkOffline);

  @override
  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  }) async => throw const AuthFailureException(AuthFailure.networkOffline);

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  }) async => throw const AuthFailureException(AuthFailure.networkOffline);

  @override
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  }) async => throw const AuthFailureException(AuthFailure.networkOffline);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resendConfirmation({required String email}) async {}
}

final class FakeGuestIdentityStore implements GuestIdentityStore {
  @override
  Future<String> currentOrCreateGuestId() async => 'guest-1';

  @override
  Future<String> currentLocalUserId() async => 'guest-1';

  @override
  Future<void> ensureProfile(String userId) async {}

  @override
  Future<void> linkGuestToSupabaseUid({
    required String guestId,
    required String supabaseUid,
  }) async {}

  @override
  Future<void> activateAccount(String accountId) async {}

  @override
  Future<void> resetForSignOut() async {}
}

/// Builds a container wired with offline auth, a stable guest identity, the
/// given onboarding repository, and an enabled in-memory analytics sink.
ProviderContainer buildOnboardingContainer({
  FakeOnboardingRepository? repository,
  InMemoryAnalyticsService? analytics,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      guestIdentityStoreProvider.overrideWithValue(FakeGuestIdentityStore()),
      onboardingRepositoryProvider.overrideWithValue(
        repository ?? FakeOnboardingRepository(),
      ),
      analyticsServiceProvider.overrideWithValue(
        analytics ?? InMemoryAnalyticsService(enabled: true),
      ),
    ],
  );
}
