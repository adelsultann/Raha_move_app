import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_account.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import 'offline_auth_repository.dart';

/// Production [AuthRepository] backed by a live Supabase GoTrue client.
///
/// Provider exceptions are translated into [AuthFailureException] with a typed
/// [AuthFailure]; raw tokens, URLs, and payloads never leave this layer.
final class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  bool get isConfigured => true;

  @override
  Stream<AuthAccount?> watchAccount() => _auth.onAuthStateChange.map(
    (state) => _accountFromUser(state.session?.user),
  );

  @override
  Future<AuthAccount?> restoreSession() async =>
      _accountFromUser(_auth.currentUser);

  @override
  Future<AuthAccount> signInAnonymously() async {
    try {
      final response = await _auth.signInAnonymously();
      return _requireAccount(response.user);
    } on AuthFailureException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw _mapNetworkError(e);
    }
  }

  @override
  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final account = _requireAccount(response.user);
      if (!account.emailConfirmed) {
        throw const AuthFailureException(AuthFailure.unconfirmed);
      }
      return account;
    } on AuthFailureException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw _mapNetworkError(e);
    }
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      final account = _accountFromUser(response.user);
      if (response.session != null &&
          account != null &&
          account.emailConfirmed) {
        return SignUpOutcome.signedIn(account);
      }
      return SignUpOutcome.needsConfirmation(email);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw _mapNetworkError(e);
    }
  }

  @override
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      return _requireAccount(response.user);
    } on AuthFailureException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw _mapNetworkError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException {
      // Best-effort: the local identity is still reset by the caller.
    }
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    try {
      await _auth.resend(email: email, type: OtpType.signup);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw _mapNetworkError(e);
    }
  }

  static AuthAccount? _accountFromUser(User? user) {
    if (user == null) return null;
    return AuthAccount(
      id: user.id,
      isAnonymous: user.isAnonymous,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  static AuthAccount _requireAccount(User? user) {
    final account = _accountFromUser(user);
    if (account == null) {
      throw const AuthFailureException(AuthFailure.unknown);
    }
    return account;
  }

  static AuthFailureException _mapAuthException(AuthException e) {
    // A retryable fetch is a network/timeout condition, not a credential error.
    if (e is AuthRetryableFetchException) {
      return const AuthFailureException(AuthFailure.networkOffline);
    }
    switch (e.code) {
      case 'invalid_credentials' || 'wrong_password' || 'user_not_found':
        return const AuthFailureException(AuthFailure.invalidCredentials);
      case 'email_exists' || 'user_already_exists':
        return const AuthFailureException(AuthFailure.emailInUse);
      case 'weak_password':
        return const AuthFailureException(AuthFailure.weakPassword);
      case 'email_not_confirmed':
        return const AuthFailureException(AuthFailure.unconfirmed);
      case 'request_timeout' ||
          'over_request_rate_limit' ||
          'over_email_send_rate_limit':
        return const AuthFailureException(AuthFailure.networkOffline);
      default:
        return const AuthFailureException(AuthFailure.unknown);
    }
  }

  static AuthFailureException _mapNetworkError(Object _) =>
      const AuthFailureException(AuthFailure.networkOffline);
}

/// Resolves the live [AuthRepository] for the current process.
///
/// When the Supabase SDK has been initialized this returns a
/// [SupabaseAuthRepository] around its client; otherwise it returns
/// [OfflineAuthRepository] so the app remains fully guest-capable and tests run
/// without a configured backend. Mirrors the "resolve live client, else null"
/// detection pattern used by user-data sync.
AuthRepository resolveLiveAuthRepository() {
  final client = _liveSupabaseClient();
  if (client == null) return const OfflineAuthRepository();
  return SupabaseAuthRepository(client);
}

SupabaseClient? _liveSupabaseClient() {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
