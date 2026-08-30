import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_account.dart';

part 'auth_repository.freezed.dart';

/// Result of a new email/password registration.
@freezed
sealed class SignUpOutcome with _$SignUpOutcome {
  /// The account was created but its email must be confirmed before sign-in.
  const factory SignUpOutcome.needsConfirmation(String email) =
      NeedsConfirmation;

  /// The account was created and signed in immediately (auto-confirm enabled).
  const factory SignUpOutcome.signedIn(AuthAccount account) = SignedIn;
}

/// The authentication boundary.
///
/// Implementations translate provider exceptions into [AuthFailureException];
/// they never leak tokens, URLs, credentials, or raw provider payloads.
abstract interface class AuthRepository {
  /// Whether a live backend is available. When false every sign-in/up method
  /// fails with [AuthFailure.networkOffline] and [watchAccount] emits null.
  bool get isConfigured;

  /// Emits the current account whenever the provider session changes.
  Stream<AuthAccount?> watchAccount();

  /// Restores a previously persisted session, or null when signed out.
  Future<AuthAccount?> restoreSession();

  Future<AuthAccount> signInAnonymously();

  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Converts the current anonymous identity into an email/password account,
  /// preserving its Supabase uid (so local history stays bound to it).
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resendConfirmation({required String email});
}
