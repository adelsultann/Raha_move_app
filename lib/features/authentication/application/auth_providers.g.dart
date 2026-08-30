// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable authentication boundary. Uses the live Supabase client when it
/// has been initialized; otherwise falls back to the offline repository so the
/// app is guest-capable and tests run without a backend.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Injectable authentication boundary. Uses the live Supabase client when it
/// has been initialized; otherwise falls back to the offline repository so the
/// app is guest-capable and tests run without a backend.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Injectable authentication boundary. Uses the live Supabase client when it
  /// has been initialized; otherwise falls back to the offline repository so the
  /// app is guest-capable and tests run without a backend.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'0acde602b2f27929ebf226c2c4bbc1563c5c0536';

/// Injectable local identity store backed by Drift.

@ProviderFor(guestIdentityStore)
final guestIdentityStoreProvider = GuestIdentityStoreProvider._();

/// Injectable local identity store backed by Drift.

final class GuestIdentityStoreProvider
    extends
        $FunctionalProvider<
          GuestIdentityStore,
          GuestIdentityStore,
          GuestIdentityStore
        >
    with $Provider<GuestIdentityStore> {
  /// Injectable local identity store backed by Drift.
  GuestIdentityStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestIdentityStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestIdentityStoreHash();

  @$internal
  @override
  $ProviderElement<GuestIdentityStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GuestIdentityStore create(Ref ref) {
    return guestIdentityStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuestIdentityStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuestIdentityStore>(value),
    );
  }
}

String _$guestIdentityStoreHash() =>
    r'6f2846a6e4d908f4e66086a72281f50ccc6c5790';
