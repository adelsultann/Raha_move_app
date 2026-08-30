import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_service.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';

import '../../features/exercise_library/data/release_fixture.dart';

void main() {
  late AppDatabase database;
  late ContentReleaseRepository repository;
  final appliedAt = DateTime.utc(2026, 8, 29, 12);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ContentReleaseRepository(database, clock: () => appliedAt);
  });

  tearDown(() => database.close());

  CatalogBootstrapService service(ContentReleaseSource source) {
    final starterManifest = minimalValidManifest(
      releaseId: '0',
      releaseVersion: 'starter-1',
    );
    final wire = jsonEncode({
      'manifest_checksum': canonicalManifestChecksum(
        CanonicalJson.encodeBytes(starterManifest),
      ),
      'manifest': starterManifest,
    });
    return CatalogBootstrapService(
      repository: repository,
      starterContent: BundledStarterContent(loadString: (_) async => wire),
      source: source,
      appVersion: '1.0.0',
    );
  }

  test(
    'applies bundled starter first, then reports no release available',
    () async {
      final result = await service(const _FakeSource(null)).run();

      expect(result.source, CatalogBootstrapSource.bundled);
      expect(result.errorCode, isNull);
      expect(result.currentReleaseId, '0');
      expect(await repository.hasCurrentRelease(), isTrue);
    },
  );

  test('applies bundled then a server release', () async {
    final server = envelopeFor(
      minimalValidManifest(releaseId: '1', releaseVersion: 'release-1'),
    );
    final result = await service(_FakeSource(server)).run();

    expect(result.source, CatalogBootstrapSource.server);
    expect(result.errorCode, isNull);
    expect(result.currentReleaseId, '1');
  });

  test('retains the bundled catalog when the source fails', () async {
    final result = await service(const _ThrowingSource()).run();

    expect(result.source, CatalogBootstrapSource.bundled);
    expect(result.errorCode, 'sync_unavailable');
    expect(result.currentReleaseId, '0');
    expect(await repository.hasCurrentRelease(), isTrue);
    // The routine is still published and readable offline.
    final routines = await LocalContentRepository(database)
        .watchPublishedRoutines()
        .first;
    expect(routines.single.id, 'raha_rt_000001');
  });

  test('skips bundled when a release already exists', () async {
    await service(const _FakeSource(null)).run();

    final result = await service(
      _FakeSource(
        envelopeFor(
          minimalValidManifest(releaseId: '1', releaseVersion: 'release-1'),
        ),
      ),
    ).run();

    expect(result.source, CatalogBootstrapSource.server);
    expect(result.currentReleaseId, '1');
  });

  test(
    'reports a recoverable error when the bundled asset is corrupt',
    () async {
      final corrupt = CatalogBootstrapService(
        repository: repository,
        starterContent: BundledStarterContent(
          loadString: (_) async => throw Exception('corrupt'),
        ),
        source: const _FakeSource(null),
        appVersion: '1.0.0',
      );

      final result = await corrupt.run();

      expect(result.isClean, isFalse);
      expect(result.errorCode, 'bootstrap_failed');
      expect(result.currentReleaseId, '');
      expect(await repository.hasCurrentRelease(), isFalse);
    },
  );
}

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
