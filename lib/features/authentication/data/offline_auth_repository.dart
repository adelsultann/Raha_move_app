import '../domain/auth_account.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

/// Offline [AuthRepository] used when no Supabase client is configured.
///
/// It keeps the application guest-capable and the test suite runnable without a
/// backend: every network operation fails with [AuthFailure.networkOffline].
final class OfflineAuthRepository implements AuthRepository {
  const OfflineAuthRepository();

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
  Future<void> resendConfirmation({required String email}) async =>
      throw const AuthFailureException(AuthFailure.networkOffline);
}
