// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Authentication owns this value and must override it with the current
/// anonymous/authenticated Supabase user plus the server entitlement snapshot.

@ProviderFor(mediaAccessScope)
final mediaAccessScopeProvider = MediaAccessScopeProvider._();

/// Authentication owns this value and must override it with the current
/// anonymous/authenticated Supabase user plus the server entitlement snapshot.

final class MediaAccessScopeProvider
    extends
        $FunctionalProvider<
          MediaAccessScope?,
          MediaAccessScope?,
          MediaAccessScope?
        >
    with $Provider<MediaAccessScope?> {
  /// Authentication owns this value and must override it with the current
  /// anonymous/authenticated Supabase user plus the server entitlement snapshot.
  MediaAccessScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaAccessScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaAccessScopeHash();

  @$internal
  @override
  $ProviderElement<MediaAccessScope?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaAccessScope? create(Ref ref) {
    return mediaAccessScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaAccessScope? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaAccessScope?>(value),
    );
  }
}

String _$mediaAccessScopeHash() => r'717ced5f547bc324d9554138e9449b05d68d1927';

@ProviderFor(mediaCacheIndex)
final mediaCacheIndexProvider = MediaCacheIndexProvider._();

final class MediaCacheIndexProvider
    extends
        $FunctionalProvider<MediaCacheIndex, MediaCacheIndex, MediaCacheIndex>
    with $Provider<MediaCacheIndex> {
  MediaCacheIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaCacheIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaCacheIndexHash();

  @$internal
  @override
  $ProviderElement<MediaCacheIndex> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaCacheIndex create(Ref ref) {
    return mediaCacheIndex(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaCacheIndex value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaCacheIndex>(value),
    );
  }
}

String _$mediaCacheIndexHash() => r'88b6f48d6871740f0948f5245d3b3cf9a34a798a';

@ProviderFor(mediaFileStore)
final mediaFileStoreProvider = MediaFileStoreProvider._();

final class MediaFileStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediaFileStore>,
          MediaFileStore,
          FutureOr<MediaFileStore>
        >
    with $FutureModifier<MediaFileStore>, $FutureProvider<MediaFileStore> {
  MediaFileStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaFileStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaFileStoreHash();

  @$internal
  @override
  $FutureProviderElement<MediaFileStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MediaFileStore> create(Ref ref) {
    return mediaFileStore(ref);
  }
}

String _$mediaFileStoreHash() => r'7312836d548f9bb2138aec8ec365aa4762ac276f';

@ProviderFor(mediaNetworkStatus)
final mediaNetworkStatusProvider = MediaNetworkStatusProvider._();

final class MediaNetworkStatusProvider
    extends
        $FunctionalProvider<
          MediaNetworkStatus,
          MediaNetworkStatus,
          MediaNetworkStatus
        >
    with $Provider<MediaNetworkStatus> {
  MediaNetworkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaNetworkStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaNetworkStatusHash();

  @$internal
  @override
  $ProviderElement<MediaNetworkStatus> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaNetworkStatus create(Ref ref) {
    return mediaNetworkStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaNetworkStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaNetworkStatus>(value),
    );
  }
}

String _$mediaNetworkStatusHash() =>
    r'ae8653576533700a097489014b43b2affb8e53bc';

@ProviderFor(mediaDownloadClient)
final mediaDownloadClientProvider = MediaDownloadClientProvider._();

final class MediaDownloadClientProvider
    extends
        $FunctionalProvider<
          MediaDownloadClient,
          MediaDownloadClient,
          MediaDownloadClient
        >
    with $Provider<MediaDownloadClient> {
  MediaDownloadClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaDownloadClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaDownloadClientHash();

  @$internal
  @override
  $ProviderElement<MediaDownloadClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaDownloadClient create(Ref ref) {
    return mediaDownloadClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaDownloadClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaDownloadClient>(value),
    );
  }
}

String _$mediaDownloadClientHash() =>
    r'163e489e437a79c83422390d9e4f938f6b89fc8d';

@ProviderFor(trustedMediaResolver)
final trustedMediaResolverProvider = TrustedMediaResolverProvider._();

final class TrustedMediaResolverProvider
    extends
        $FunctionalProvider<
          TrustedMediaResolver,
          TrustedMediaResolver,
          TrustedMediaResolver
        >
    with $Provider<TrustedMediaResolver> {
  TrustedMediaResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedMediaResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedMediaResolverHash();

  @$internal
  @override
  $ProviderElement<TrustedMediaResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrustedMediaResolver create(Ref ref) {
    return trustedMediaResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrustedMediaResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrustedMediaResolver>(value),
    );
  }
}

String _$trustedMediaResolverHash() =>
    r'5b933148eca07be49b91b88c629407e151fba2fe';

@ProviderFor(mediaCacheLifecycle)
final mediaCacheLifecycleProvider = MediaCacheLifecycleProvider._();

final class MediaCacheLifecycleProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediaCacheLifecycle>,
          MediaCacheLifecycle,
          FutureOr<MediaCacheLifecycle>
        >
    with
        $FutureModifier<MediaCacheLifecycle>,
        $FutureProvider<MediaCacheLifecycle> {
  MediaCacheLifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaCacheLifecycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaCacheLifecycleHash();

  @$internal
  @override
  $FutureProviderElement<MediaCacheLifecycle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MediaCacheLifecycle> create(Ref ref) {
    return mediaCacheLifecycle(ref);
  }
}

String _$mediaCacheLifecycleHash() =>
    r'461b5a882bd4a229050b78282d1928702d457456';

@ProviderFor(mediaPreparationService)
final mediaPreparationServiceProvider = MediaPreparationServiceProvider._();

final class MediaPreparationServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediaPreparationService?>,
          MediaPreparationService?,
          FutureOr<MediaPreparationService?>
        >
    with
        $FutureModifier<MediaPreparationService?>,
        $FutureProvider<MediaPreparationService?> {
  MediaPreparationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaPreparationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaPreparationServiceHash();

  @$internal
  @override
  $FutureProviderElement<MediaPreparationService?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MediaPreparationService?> create(Ref ref) {
    return mediaPreparationService(ref);
  }
}

String _$mediaPreparationServiceHash() =>
    r'e83af1b4cc3366b4529814b9b1e6d2f6510574d7';

@ProviderFor(routineMediaPlaybackCoordinator)
final routineMediaPlaybackCoordinatorProvider =
    RoutineMediaPlaybackCoordinatorProvider._();

final class RoutineMediaPlaybackCoordinatorProvider
    extends
        $FunctionalProvider<
          AsyncValue<RoutineMediaPlaybackCoordinator?>,
          RoutineMediaPlaybackCoordinator?,
          FutureOr<RoutineMediaPlaybackCoordinator?>
        >
    with
        $FutureModifier<RoutineMediaPlaybackCoordinator?>,
        $FutureProvider<RoutineMediaPlaybackCoordinator?> {
  RoutineMediaPlaybackCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineMediaPlaybackCoordinatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineMediaPlaybackCoordinatorHash();

  @$internal
  @override
  $FutureProviderElement<RoutineMediaPlaybackCoordinator?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RoutineMediaPlaybackCoordinator?> create(Ref ref) {
    return routineMediaPlaybackCoordinator(ref);
  }
}

String _$routineMediaPlaybackCoordinatorHash() =>
    r'f865002ad126bb7310735207ee481e020803bf7e';
