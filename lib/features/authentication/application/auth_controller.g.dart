// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-owned authentication lifecycle.
///
/// It establishes a stable guest identity immediately (never blocking offline
/// use), then best-effort links an anonymous session and promotes the guest
/// identity to the Supabase uid. Explicit actions cover sign-in, sign-up,
/// anonymous→email upgrade, sign-out, retry, and confirmation resend.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// App-owned authentication lifecycle.
///
/// It establishes a stable guest identity immediately (never blocking offline
/// use), then best-effort links an anonymous session and promotes the guest
/// identity to the Supabase uid. Explicit actions cover sign-in, sign-up,
/// anonymous→email upgrade, sign-out, retry, and confirmation resend.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthState> {
  /// App-owned authentication lifecycle.
  ///
  /// It establishes a stable guest identity immediately (never blocking offline
  /// use), then best-effort links an anonymous session and promotes the guest
  /// identity to the Supabase uid. Explicit actions cover sign-in, sign-up,
  /// anonymous→email upgrade, sign-out, retry, and confirmation resend.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'8ac3b11b97492eb13beaa9472f8a7232c5edb8db';

/// App-owned authentication lifecycle.
///
/// It establishes a stable guest identity immediately (never blocking offline
/// use), then best-effort links an anonymous session and promotes the guest
/// identity to the Supabase uid. Explicit actions cover sign-in, sign-up,
/// anonymous→email upgrade, sign-out, retry, and confirmation resend.

abstract class _$AuthController extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
