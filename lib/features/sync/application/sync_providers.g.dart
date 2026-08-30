// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The currently authenticated user id, or null when signed out. Owned by the
/// authentication feature; it is declared here so the sync coordinator has one
/// app-owned, stable signal for "who may sync now". It derives from the auth
/// controller's active user id (null only while the controller is initializing)
/// and stays overridable for tests.

@ProviderFor(activeUserId)
final activeUserIdProvider = ActiveUserIdProvider._();

/// The currently authenticated user id, or null when signed out. Owned by the
/// authentication feature; it is declared here so the sync coordinator has one
/// app-owned, stable signal for "who may sync now". It derives from the auth
/// controller's active user id (null only while the controller is initializing)
/// and stays overridable for tests.

final class ActiveUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The currently authenticated user id, or null when signed out. Owned by the
  /// authentication feature; it is declared here so the sync coordinator has one
  /// app-owned, stable signal for "who may sync now". It derives from the auth
  /// controller's active user id (null only while the controller is initializing)
  /// and stays overridable for tests.
  ActiveUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return activeUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeUserIdHash() => r'642d152f7415de1bc02d95407cf98c77a0124461';

/// Injectable RPC gateway for user-data sync. Uses the live Supabase client
/// when it has been initialized, and otherwise falls back to the offline no-op
/// so the application compiles and runs without a backend.

@ProviderFor(syncRpcGateway)
final syncRpcGatewayProvider = SyncRpcGatewayProvider._();

/// Injectable RPC gateway for user-data sync. Uses the live Supabase client
/// when it has been initialized, and otherwise falls back to the offline no-op
/// so the application compiles and runs without a backend.

final class SyncRpcGatewayProvider
    extends $FunctionalProvider<SyncRpcGateway, SyncRpcGateway, SyncRpcGateway>
    with $Provider<SyncRpcGateway> {
  /// Injectable RPC gateway for user-data sync. Uses the live Supabase client
  /// when it has been initialized, and otherwise falls back to the offline no-op
  /// so the application compiles and runs without a backend.
  SyncRpcGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRpcGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRpcGatewayHash();

  @$internal
  @override
  $ProviderElement<SyncRpcGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncRpcGateway create(Ref ref) {
    return syncRpcGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncRpcGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncRpcGateway>(value),
    );
  }
}

String _$syncRpcGatewayHash() => r'21601df658b0aa2404951613427f84f7fbc05330';

/// Injectable boundary to the trusted user-data sync API. When the gateway is
/// unconfigured or the bound user is unauthenticated the transport reports
/// [SyncUnavailable] so the outbox is retained without consuming retry budget.

@ProviderFor(syncTransport)
final syncTransportProvider = SyncTransportFamily._();

/// Injectable boundary to the trusted user-data sync API. When the gateway is
/// unconfigured or the bound user is unauthenticated the transport reports
/// [SyncUnavailable] so the outbox is retained without consuming retry budget.

final class SyncTransportProvider
    extends $FunctionalProvider<SyncTransport, SyncTransport, SyncTransport>
    with $Provider<SyncTransport> {
  /// Injectable boundary to the trusted user-data sync API. When the gateway is
  /// unconfigured or the bound user is unauthenticated the transport reports
  /// [SyncUnavailable] so the outbox is retained without consuming retry budget.
  SyncTransportProvider._({
    required SyncTransportFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'syncTransportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$syncTransportHash();

  @override
  String toString() {
    return r'syncTransportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SyncTransport> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncTransport create(Ref ref) {
    final argument = this.argument as String;
    return syncTransport(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncTransport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncTransport>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SyncTransportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$syncTransportHash() => r'd0bdb068b94f32cc18ef85847770f5227c21d913';

/// Injectable boundary to the trusted user-data sync API. When the gateway is
/// unconfigured or the bound user is unauthenticated the transport reports
/// [SyncUnavailable] so the outbox is retained without consuming retry budget.

final class SyncTransportFamily extends $Family
    with $FunctionalFamilyOverride<SyncTransport, String> {
  SyncTransportFamily._()
    : super(
        retry: null,
        name: r'syncTransportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Injectable boundary to the trusted user-data sync API. When the gateway is
  /// unconfigured or the bound user is unauthenticated the transport reports
  /// [SyncUnavailable] so the outbox is retained without consuming retry budget.

  SyncTransportProvider call(String activeUserId) =>
      SyncTransportProvider._(argument: activeUserId, from: this);

  @override
  String toString() => r'syncTransportProvider';
}

/// The user-data sync engine for the active user. Bound to one user because
/// outbox acknowledgement, cursor, and projection writes are owner-scoped.

@ProviderFor(userDataSyncEngine)
final userDataSyncEngineProvider = UserDataSyncEngineFamily._();

/// The user-data sync engine for the active user. Bound to one user because
/// outbox acknowledgement, cursor, and projection writes are owner-scoped.

final class UserDataSyncEngineProvider
    extends
        $FunctionalProvider<
          UserDataSyncEngine,
          UserDataSyncEngine,
          UserDataSyncEngine
        >
    with $Provider<UserDataSyncEngine> {
  /// The user-data sync engine for the active user. Bound to one user because
  /// outbox acknowledgement, cursor, and projection writes are owner-scoped.
  UserDataSyncEngineProvider._({
    required UserDataSyncEngineFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userDataSyncEngineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userDataSyncEngineHash();

  @override
  String toString() {
    return r'userDataSyncEngineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<UserDataSyncEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserDataSyncEngine create(Ref ref) {
    final argument = this.argument as String;
    return userDataSyncEngine(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDataSyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDataSyncEngine>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserDataSyncEngineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userDataSyncEngineHash() =>
    r'40e4920a0a58bb21fff179a7e38be7829aab5bd8';

/// The user-data sync engine for the active user. Bound to one user because
/// outbox acknowledgement, cursor, and projection writes are owner-scoped.

final class UserDataSyncEngineFamily extends $Family
    with $FunctionalFamilyOverride<UserDataSyncEngine, String> {
  UserDataSyncEngineFamily._()
    : super(
        retry: null,
        name: r'userDataSyncEngineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The user-data sync engine for the active user. Bound to one user because
  /// outbox acknowledgement, cursor, and projection writes are owner-scoped.

  UserDataSyncEngineProvider call(String activeUserId) =>
      UserDataSyncEngineProvider._(argument: activeUserId, from: this);

  @override
  String toString() => r'userDataSyncEngineProvider';
}
