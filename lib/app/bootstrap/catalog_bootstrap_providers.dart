import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'catalog_bootstrap_service.dart';

part 'catalog_bootstrap_providers.g.dart';

/// The local database used by bootstrap. Defaults to an in-memory executor so
/// the application compiles and tests run without platform plugins; the
/// durable, file-backed executor (with `path_provider` and
/// `sqlite3_flutter_libs`/`sqflite`) is wired by the database/storage owner.
/// Tests override this provider with an isolated in-memory database.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase(NativeDatabase.memory());

/// Injectable catalog source. Defaults to an offline no-op so no live SDK or
/// configuration is required; override with a real source when one exists.
@Riverpod(keepAlive: true)
ContentReleaseSource contentReleaseSource(Ref ref) =>
    const NoopContentReleaseSource();

/// Loads the bundled starter manifest from the Flutter asset bundle.
@Riverpod(keepAlive: true)
BundledStarterContent bundledStarterContent(Ref ref) =>
    BundledStarterContent(loadString: (path) => rootBundle.loadString(path));

/// The running application version used for release compatibility checks.
@Riverpod(keepAlive: true)
String appVersion(Ref ref) =>
    const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

@riverpod
CatalogBootstrapService catalogBootstrapService(Ref ref) {
  return CatalogBootstrapService(
    repository: ContentReleaseRepository(ref.watch(appDatabaseProvider)),
    starterContent: ref.watch(bundledStarterContentProvider),
    source: ref.watch(contentReleaseSourceProvider),
    appVersion: ref.watch(appVersionProvider),
  );
}

/// Application-owned bootstrap/sync state. It applies the bundled catalog first
/// and then attempts a remote sync, retaining local content on error. Watch
/// this from app startup and call [retry] from a recoverable error state.
@Riverpod(keepAlive: true)
class CatalogBootstrap extends _$CatalogBootstrap {
  @override
  Future<CatalogBootstrapResult> build() =>
      ref.read(catalogBootstrapServiceProvider).run();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catalogBootstrapServiceProvider).run(),
    );
  }
}
