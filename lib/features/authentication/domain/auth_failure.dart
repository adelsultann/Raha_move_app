/// A domain-level authentication failure.
///
/// Deliberately free of raw tokens, URLs, credentials, provider ids, or any
/// sensitive payload. The presentation layer maps each value to a localized
/// message.
enum AuthFailure {
  invalidCredentials,
  emailInUse,
  weakPassword,
  networkOffline,
  cancelled,
  unconfirmed,
  unknown,
}

/// Thrown by `AuthRepository` implementations when an operation fails, carrying
/// a translated [AuthFailure] so callers never inspect provider exceptions or
/// error bodies directly.
final class AuthFailureException implements Exception {
  const AuthFailureException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthFailureException(${failure.name})';
}
