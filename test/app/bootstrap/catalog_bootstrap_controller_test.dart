import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_service.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';

import '../../features/exercise_library/data/release_fixture.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  ProviderContainer container(ContentReleaseSource source) {
    final starterManifest = minimalValidManifest(
      releaseId: '0',
      releaseVersion: 'starter-1',
    );
    final raw = encodeWire(starterManifest);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        contentReleaseSourceProvider.overrideWithValue(source),
        bundledStarterContentProvider.overrideWithValue(
          BundledStarterContent(loadString: (_) async => raw),
        ),
        appVersionProvider.overrideWithValue('1.0.0'),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('bootstrap applies bundled content on a fresh install', () async {
    final result = await container(const _FakeSource(null))
        .read(catalogBootstrapProvider.future);

    expect(result.source, CatalogBootstrapSource.bundled);
    expect(result.currentReleaseId, '0');
    expect(result.isClean, isTrue);
  });

  test(
    'retry picks up a server release after an initial offline pass',
    () async {
      final server = envelopeFor(
        minimalValidManifest(releaseId: '1', releaseVersion: 'release-1'),
      );
      final c = container(_SequencedSource([null, server]));

      final first = await c.read(catalogBootstrapProvider.future);
      expect(first.source, CatalogBootstrapSource.bundled);

      await c.read(catalogBootstrapProvider.notifier).retry();

      final state = c.read(catalogBootstrapProvider);
      expect(state.value?.source, CatalogBootstrapSource.server);
      expect(state.value?.currentReleaseId, '1');
    },
  );

  test('an offline source still leaves a usable catalog', () async {
    final result = await container(const _ThrowingSource())
        .read(catalogBootstrapProvider.future);

    expect(result.source, CatalogBootstrapSource.bundled);
    expect(result.errorCode, 'sync_unavailable');
    expect(result.currentReleaseId, '0');
  });

  test(
    'a failing bundled asset reaches a recoverable error state once',
    () async {
      var calls = 0;
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          contentReleaseSourceProvider.overrideWithValue(
            const NoopContentReleaseSource(),
          ),
          bundledStarterContentProvider.overrideWithValue(
            BundledStarterContent(
              loadString: (_) async {
                calls++;
                throw Exception('corrupt asset');
              },
            ),
          ),
          appVersionProvider.overrideWithValue('1.0.0'),
        ],
      );
      addTearDown(c.dispose);

      final result = await c.read(catalogBootstrapProvider.future);

      expect(result.isClean, isFalse);
      expect(result.errorCode, 'bootstrap_failed');
      expect(result.currentReleaseId, '');
      expect(calls, 1);
    },
  );
}

String encodeWire(Map<String, dynamic> manifest) => jsonEncode({
  'manifest_checksum': canonicalManifestChecksum(
    CanonicalJson.encodeBytes(manifest),
  ),
  'manifest': manifest,
});

final class _FakeSource implements ContentReleaseSource {
  const _FakeSource(this.next);

  final ContentReleaseEnvelope? next;

  @override
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  }) async => next;
}

final class _ThrowingSource implements ContentReleaseSource {
  const _ThrowingSource();

  @override
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  }) => throw StateError('offline');
}

final class _SequencedSource implements ContentReleaseSource {
  _SequencedSource(this.results);

  final List<ContentReleaseEnvelope?> results;
  int _index = 0;

  @override
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  }) async {
    final result = _index < results.length ? results[_index] : null;
    _index++;
    return result;
  }
}
