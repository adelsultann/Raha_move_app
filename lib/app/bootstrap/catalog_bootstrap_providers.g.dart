// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_bootstrap_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The local database used by bootstrap. Defaults to an in-memory executor so
/// the application compiles and tests run without platform plugins; the
/// durable, file-backed executor (with `path_provider` and
/// `sqlite3_flutter_libs`/`sqflite`) is wired by the database/storage owner.
/// Tests override this provider with an isolated in-memory database.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The local database used by bootstrap. Defaults to an in-memory executor so
/// the application compiles and tests run without platform plugins; the
/// durable, file-backed executor (with `path_provider` and
/// `sqlite3_flutter_libs`/`sqflite`) is wired by the database/storage owner.
/// Tests override this provider with an isolated in-memory database.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The local database used by bootstrap. Defaults to an in-memory executor so
  /// the application compiles and tests run without platform plugins; the
  /// durable, file-backed executor (with `path_provider` and
  /// `sqlite3_flutter_libs`/`sqflite`) is wired by the database/storage owner.
  /// Tests override this provider with an isolated in-memory database.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'ae35d057ca72b3345b01e3dbbf17d2f480581e4e';

/// Injectable catalog source. Defaults to an offline no-op so no live SDK or
/// configuration is required; override with a real source when one exists.

@ProviderFor(contentReleaseSource)
final contentReleaseSourceProvider = ContentReleaseSourceProvider._();

/// Injectable catalog source. Defaults to an offline no-op so no live SDK or
/// configuration is required; override with a real source when one exists.

final class ContentReleaseSourceProvider
    extends
        $FunctionalProvider<
          ContentReleaseSource,
          ContentReleaseSource,
          ContentReleaseSource
        >
    with $Provider<ContentReleaseSource> {
  /// Injectable catalog source. Defaults to an offline no-op so no live SDK or
  /// configuration is required; override with a real source when one exists.
  ContentReleaseSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentReleaseSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentReleaseSourceHash();

  @$internal
  @override
  $ProviderElement<ContentReleaseSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContentReleaseSource create(Ref ref) {
    return contentReleaseSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentReleaseSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentReleaseSource>(value),
    );
  }
}

String _$contentReleaseSourceHash() =>
    r'd35ebd1a1a213e97eae6a629f66ad4a0d1a14e81';

/// Loads the bundled starter manifest from the Flutter asset bundle.

@ProviderFor(bundledStarterContent)
final bundledStarterContentProvider = BundledStarterContentProvider._();

/// Loads the bundled starter manifest from the Flutter asset bundle.

final class BundledStarterContentProvider
    extends
        $FunctionalProvider<
          BundledStarterContent,
          BundledStarterContent,
          BundledStarterContent
        >
    with $Provider<BundledStarterContent> {
  /// Loads the bundled starter manifest from the Flutter asset bundle.
  BundledStarterContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bundledStarterContentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bundledStarterContentHash();

  @$internal
  @override
  $ProviderElement<BundledStarterContent> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BundledStarterContent create(Ref ref) {
    return bundledStarterContent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BundledStarterContent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BundledStarterContent>(value),
    );
  }
}

String _$bundledStarterContentHash() =>
    r'c0dce788522b426c3a1c713bd36fb70df8930546';

/// The running application version used for release compatibility checks.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The running application version used for release compatibility checks.

final class AppVersionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The running application version used for release compatibility checks.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appVersionHash() => r'801ad672c87efb44b267a3e95beeea4415f1fd96';

@ProviderFor(catalogBootstrapService)
final catalogBootstrapServiceProvider = CatalogBootstrapServiceProvider._();

final class CatalogBootstrapServiceProvider
    extends
        $FunctionalProvider<
          CatalogBootstrapService,
          CatalogBootstrapService,
          CatalogBootstrapService
        >
    with $Provider<CatalogBootstrapService> {
  CatalogBootstrapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogBootstrapServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogBootstrapServiceHash();

  @$internal
  @override
  $ProviderElement<CatalogBootstrapService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogBootstrapService create(Ref ref) {
    return catalogBootstrapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogBootstrapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogBootstrapService>(value),
    );
  }
}

String _$catalogBootstrapServiceHash() =>
    r'6be5c2c0e8aa954028626af8534992043f709475';

/// Application-owned bootstrap/sync state. It applies the bundled catalog first
/// and then attempts a remote sync, retaining local content on error. Watch
/// this from app startup and call [retry] from a recoverable error state.

@ProviderFor(CatalogBootstrap)
final catalogBootstrapProvider = CatalogBootstrapProvider._();

/// Application-owned bootstrap/sync state. It applies the bundled catalog first
/// and then attempts a remote sync, retaining local content on error. Watch
/// this from app startup and call [retry] from a recoverable error state.
final class CatalogBootstrapProvider
    extends $AsyncNotifierProvider<CatalogBootstrap, CatalogBootstrapResult> {
  /// Application-owned bootstrap/sync state. It applies the bundled catalog first
  /// and then attempts a remote sync, retaining local content on error. Watch
  /// this from app startup and call [retry] from a recoverable error state.
  CatalogBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogBootstrapHash();

  @$internal
  @override
  CatalogBootstrap create() => CatalogBootstrap();
}

String _$catalogBootstrapHash() => r'553313b9aece3db690f3ac5699655669cf2fdcac';

/// Application-owned bootstrap/sync state. It applies the bundled catalog first
/// and then attempts a remote sync, retaining local content on error. Watch
/// this from app startup and call [retry] from a recoverable error state.

abstract class _$CatalogBootstrap
    extends $AsyncNotifier<CatalogBootstrapResult> {
  FutureOr<CatalogBootstrapResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CatalogBootstrapResult>, CatalogBootstrapResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CatalogBootstrapResult>,
                CatalogBootstrapResult
              >,
              AsyncValue<CatalogBootstrapResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
