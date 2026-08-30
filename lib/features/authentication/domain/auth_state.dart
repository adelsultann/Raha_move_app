import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_failure.dart';

part 'auth_state.freezed.dart';

/// Coarse lifecycle of the app-facing identity.
enum AuthStatus { guest, anonymous, authenticated }

/// App-facing authentication state.
///
/// [activeUserId] is the local Drift identity: a guest UUID while offline, and
/// the Supabase auth uid after linking/adopting an account. It is null only
/// while the controller is initializing (before a guest id exists).
@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    required String? activeUserId,
    required AuthStatus status,
    @Default(false) bool isBusy,
    @Default(false) bool emailConfirmed,
    String? pendingEmail,
    AuthFailure? failure,
  }) = _AuthState;

  /// Whether a Supabase identity (anonymous or authenticated) currently exists.
  bool get hasSupabaseIdentity => status != AuthStatus.guest;

  /// The Supabase owner id that authorizes media cache bytes, or null while
  /// guest/offline (no Supabase identity). This is never the guest UUID.
  String? get mediaOwnerId => status == AuthStatus.guest ? null : activeUserId;
}
