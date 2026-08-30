import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/media/application/media_cache_lifecycle.dart';
import 'package:raha_move/features/media/application/media_preparation_service.dart';
import 'package:raha_move/features/media/application/routine_media_playback_coordinator.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  MediaDelivery media(String id, List<int> bytes, {String version = 'v1'}) =>
      MediaDelivery(
        mediaId: id,
        deliveryReference: 'opaque-reference-$id',
        version: version,
        checksumSha256: sha256.convert(bytes).toString(),
      );

  _Harness harness({
    MediaNetwork network = MediaNetwork.wifi,
    int availableBytes = 1024 * 1024,
    int maximumCacheBytes = 500 * 1024 * 1024,
    String ownerId = 'owner-a',
    Iterable<MediaEntitlement> entitlements = const [],
  }) => _Harness(
    now: now,
    network: network,
    availableBytes: availableBytes,
    maximumCacheBytes: maximumCacheBytes,
    ownerId: ownerId,
    entitlements: entitlements,
  );

  test('resolves opaque references without persisting ephemeral URL', () async {
    final h = harness();
    final target = media('media-1', [1, 2, 3]);
    h.downloader.responses[target.mediaId] = Uint8List.fromList([1, 2, 3]);

    final result = await h.service.prepareActiveRoutine([
      target,
    ], explicitUserStart: true);

    expect(result.results['media-1'], isA<MediaPrepared>());
    expect(h.resolver.references, ['opaque-reference-media-1']);
    expect(h.cache.values.values.single.path, isNot(contains('https://')));
    expect(
      h.cache.values.values.single.path,
      isNot(contains('opaque-reference')),
    );
    expect(h.files.paths.keys.single, isNot(contains('https://')));
  });

  test('prepares all active media and preloads next media on Wi-Fi', () async {
    final h = harness();
    final first = media('first', [1]);
    final second = media('second', [2]);
    final next = media('next', [3]);
    h.downloader.responses.addAll({
      'first': Uint8List.fromList([1]),
      'second': Uint8List.fromList([2]),
      'next': Uint8List.fromList([3]),
    });

    final active = await h.service.prepareActiveRoutine(
      [first, second],
      explicitUserStart: false,
      nextToPreloadMediaIds: ['next'],
    );
    final preloaded = await h.service.preloadNext(
      next,
      activeRoutineMediaIds: ['first', 'second'],
    );

    expect(active.allReady, isTrue);
    expect(preloaded, isA<MediaPrepared>());
    expect(h.cached('first'), isNotNull);
    expect(h.cached('second'), isNotNull);
    expect(h.cached('next'), isNotNull);
  });

  test(
    'routine-player boundary prepares the routine and preloads next',
    () async {
      final h = harness();
      final first = media('first', [1]);
      final next = media('next', [2]);
      h.downloader.responses.addAll({
        'first': Uint8List.fromList([1]),
        'next': Uint8List.fromList([2]),
      });
      final coordinator = RoutineMediaPlaybackCoordinator(h.service);

      final prepared = await coordinator.prepareForStart([
        first,
        next,
      ], explicitUserStart: true);
      final preloaded = await coordinator.preloadAfterStep([
        first,
        next,
      ], currentStepIndex: 0);

      expect(prepared.allReady, isTrue);
      expect(preloaded, isA<MediaPrepared>());
      expect(h.cached('next'), isNotNull);
    },
  );

  test(
    'replaces stale or corrupt cache only after SHA-256 verification',
    () async {
      final h = harness();
      final target = media('media-1', [9, 8, 7], version: 'v2');
      h.cache.put(
        CachedMedia(
          ownerId: h.ownerId,
          mediaId: target.mediaId,
          path: 'cache/media-1-old',
          version: 'v1',
          checksumSha256: sha256.convert([0]).toString(),
          requiredEntitlement: null,
          byteSize: 1,
          lastVerifiedAccess: now,
        ),
      );
      h.files.paths['cache/media-1-old'] = Uint8List.fromList([0]);
      h.downloader.responses[target.mediaId] = Uint8List.fromList([9, 8, 7]);

      final result = await h.service.prepareActiveRoutine([
        target,
      ], explicitUserStart: true);

      expect(
        result.results['media-1'],
        isA<MediaPrepared>().having(
          (value) => value.fromCache,
          'from cache',
          isFalse,
        ),
      );
      expect(h.cached('media-1')!.version, 'v2');
      expect(
        sha256
            .convert(await h.files.read(h.cached('media-1')!.path))
            .toString(),
        target.checksumSha256,
      );
    },
  );

  test(
    'uses an already verified cache when a later download would fail',
    () async {
      final h = harness();
      final target = media('media-1', [4, 5]);
      h.cache.put(
        CachedMedia(
          ownerId: h.ownerId,
          mediaId: target.mediaId,
          path: 'cache/media-1',
          version: target.version,
          checksumSha256: target.checksumSha256,
          requiredEntitlement: null,
          byteSize: 2,
          lastVerifiedAccess: now,
        ),
      );
      h.files.paths['cache/media-1'] = Uint8List.fromList([4, 5]);
      h.downloader.fail = true;

      final result = await h.service.retry(
        target,
        pinnedMediaIds: ['media-1'],
        explicitUserStart: true,
      );

      expect(
        result,
        isA<MediaPrepared>().having(
          (value) => value.fromCache,
          'from cache',
          isTrue,
        ),
      );
      expect(h.downloader.calls, isZero);
    },
  );

  test('evicts eligible LRU entries but never active or next pins', () async {
    final h = harness(maximumCacheBytes: 6);
    await h.seed('old', [
      1,
      1,
      1,
    ], lastAccess: now.subtract(const Duration(minutes: 2)));
    await h.seed('pinned', [
      2,
      2,
      2,
    ], lastAccess: now.subtract(const Duration(minutes: 1)));
    final target = media('target', [3, 3, 3]);
    h.downloader.responses[target.mediaId] = Uint8List.fromList([3, 3, 3]);

    final result = await h.service.retry(
      target,
      pinnedMediaIds: ['pinned', 'target'],
      explicitUserStart: true,
    );

    expect(result, isA<MediaPrepared>());
    expect(h.cached('old'), isNull);
    expect(h.cached('pinned'), isNotNull);
    expect(h.cached('target'), isNotNull);
  });

  test('automatic downloads are Wi-Fi-only while an explicit start may use cellular', () async {
    final h = harness(network: MediaNetwork.cellular);
    final target = media('media-1', [1]);
    h.downloader.responses[target.mediaId] = Uint8List.fromList([1]);

    final automatic = await h.service.preloadNext(
      target,
      activeRoutineMediaIds: const [],
    );
    final explicit = await h.service.prepareActiveRoutine([
      target,
    ], explicitUserStart: true);

    expect(
      automatic,
      isA<MediaUnavailable>().having(
        (value) => value.code,
        'code',
        MediaFailureCode.networkRestricted,
      ),
    );
    expect(explicit.allReady, isTrue);
  });

  test(
    'low storage preserves pinned verified files and returns typed recovery',
    () async {
      final h = harness(availableBytes: 1, maximumCacheBytes: 10);
      await h.seed('active', [1, 1], lastAccess: now);
      final target = media('target', [2, 2, 2]);
      h.downloader.responses[target.mediaId] = Uint8List.fromList([2, 2, 2]);

      final result = await h.service.retry(
        target,
        pinnedMediaIds: ['active', 'target'],
        explicitUserStart: true,
      );

      expect(
        result,
        isA<MediaStorageNeeded>().having(
          (value) => value.requiredBytes,
          'required bytes',
          3,
        ),
      );
      expect(h.cached('active'), isNotNull);
      expect(h.files.paths, contains('cache/active'));
    },
  );

  test(
    'a storage write failure returns recoverable storage-needed state',
    () async {
      final h = harness();
      final target = media('media-1', [1, 2, 3]);
      h.downloader.responses[target.mediaId] = Uint8List.fromList([1, 2, 3]);
      h.files.failNextWriteWithStorage = true;

      final result = await h.service.retry(
        target,
        pinnedMediaIds: [target.mediaId],
        explicitUserStart: true,
      );

      expect(
        result,
        isA<MediaStorageNeeded>().having(
          (value) => value.requiredBytes,
          'required bytes',
          3,
        ),
      );
    },
  );

  test('disk-full write evicts eligible LRU media and retries', () async {
    final h = harness();
    await h.seed('old', [
      8,
      8,
    ], lastAccess: now.subtract(const Duration(minutes: 1)));
    final target = media('target', [1, 2, 3]);
    h.downloader.responses[target.mediaId] = Uint8List.fromList([1, 2, 3]);
    h.files.failNextWriteWithStorage = true;

    final result = await h.service.retry(
      target,
      pinnedMediaIds: [target.mediaId],
      explicitUserStart: true,
    );

    expect(result, isA<MediaPrepared>());
    expect(h.cached('old'), isNull);
    expect(h.cached('target'), isNotNull);
  });

  test('private cache requires the active owner and entitlement', () async {
    final entitled = harness(
      entitlements: const [MediaEntitlement(key: 'premium')],
    );
    final target = MediaDelivery(
      mediaId: 'premium-media',
      deliveryReference: 'opaque-reference-premium-media',
      version: 'v1',
      checksumSha256: sha256.convert([7]).toString(),
      requiredEntitlement: 'premium',
    );
    entitled.downloader.responses[target.mediaId] = Uint8List.fromList([7]);
    final downloaded = await entitled.service.retry(
      target,
      pinnedMediaIds: [target.mediaId],
      explicitUserStart: true,
    );
    expect(downloaded, isA<MediaPrepared>());

    final switched = harness(ownerId: 'owner-b');
    switched.cache.values.addAll(entitled.cache.values);
    switched.files.paths.addAll(entitled.files.paths);
    final denied = await switched.service.retry(
      target,
      pinnedMediaIds: [target.mediaId],
      explicitUserStart: true,
    );
    expect(
      denied,
      isA<MediaUnavailable>().having(
        (value) => value.code,
        'code',
        MediaFailureCode.entitlementRequired,
      ),
    );
    expect(switched.downloader.calls, isZero);
  });

  test('logout/account switch purges the previous owner cache', () async {
    final h = harness();
    await h.seed('private', [9], lastAccess: now, entitlement: 'premium');
    final lifecycle = MediaCacheLifecycle(cache: h.cache, files: h.files);

    await lifecycle.onSessionChanged(
      previousOwnerId: 'owner-a',
      currentOwnerId: 'owner-b',
    );

    expect(h.cached('private'), isNull);
    expect(h.files.paths, isEmpty);
  });

  test('startup reconciliation purges cache from a stale account', () async {
    final h = harness();
    await h.seed('stale', [9], lastAccess: now, entitlement: 'premium');
    final lifecycle = MediaCacheLifecycle(cache: h.cache, files: h.files);

    await lifecycle.reconcileCurrentOwner('owner-b');

    expect(h.cached('stale'), isNull);
    expect(h.files.paths, isEmpty);
  });

  test(
    'entitlement loss purges private bytes before returning denial',
    () async {
      final h = harness();
      await h.seed('private', [9], lastAccess: now, entitlement: 'premium');
      final target = MediaDelivery(
        mediaId: 'private',
        deliveryReference: 'opaque-reference-private',
        version: 'v1',
        checksumSha256: sha256.convert([9]).toString(),
        requiredEntitlement: 'premium',
      );

      final result = await h.service.retry(
        target,
        pinnedMediaIds: [target.mediaId],
        explicitUserStart: true,
      );

      expect(result, isA<MediaUnavailable>());
      expect(h.cached('private'), isNull);
      expect(h.files.paths, isEmpty);
    },
  );

  test(
    'failed entitlement purge keeps the index fail-closed for retry',
    () async {
      final h = harness();
      await h.seed('private', [9], lastAccess: now, entitlement: 'premium');
      h.files.failDelete = true;
      final target = MediaDelivery(
        mediaId: 'private',
        deliveryReference: 'opaque-reference-private',
        version: 'v1',
        checksumSha256: sha256.convert([9]).toString(),
        requiredEntitlement: 'premium',
      );

      final result = await h.service.retry(
        target,
        pinnedMediaIds: [target.mediaId],
        explicitUserStart: true,
      );

      expect(result, isA<MediaUnavailable>());
      expect(h.cached('private'), isNotNull);
      expect(h.files.paths, isNotEmpty);
    },
  );
}

final class _Harness {
  _Harness({
    required DateTime now,
    required MediaNetwork network,
    required int availableBytes,
    required int maximumCacheBytes,
    required String ownerId,
    required Iterable<MediaEntitlement> entitlements,
  }) : cache = _FakeCache(),
       files = _FakeFiles(availableBytes),
       resolver = _FakeResolver(),
       downloader = _FakeDownloader(),
       _network = _FakeNetwork(network),
       ownerId = ownerId {
    service = MediaPreparationService(
      resolver: resolver,
      downloader: downloader,
      files: files,
      cache: cache,
      network: _network,
      accessScope: MediaAccessScope(
        ownerId: ownerId,
        entitlements: entitlements,
      ),
      clock: () => now,
      maximumCacheBytes: maximumCacheBytes,
    );
  }

  final _FakeCache cache;
  final _FakeFiles files;
  final _FakeResolver resolver;
  final _FakeDownloader downloader;
  final _FakeNetwork _network;
  final String ownerId;
  late final MediaPreparationService service;

  Future<void> seed(
    String id,
    List<int> bytes, {
    required DateTime lastAccess,
    String? entitlement,
  }) async {
    final checksum = sha256.convert(bytes).toString();
    final path = 'cache/$id';
    files.paths[path] = Uint8List.fromList(bytes);
    await cache.put(
      CachedMedia(
        ownerId: ownerId,
        mediaId: id,
        path: path,
        version: 'v1',
        checksumSha256: checksum,
        requiredEntitlement: entitlement,
        byteSize: bytes.length,
        lastVerifiedAccess: lastAccess,
      ),
    );
  }

  CachedMedia? cached(String mediaId) => cache.values['$ownerId:$mediaId'];
}

final class _FakeResolver implements TrustedMediaResolver {
  final references = <String>[];

  @override
  Future<EphemeralMediaUrl> resolve(MediaAuthorizationRequest request) async {
    references.add(request.deliveryReference);
    return EphemeralMediaUrl(
      value: Uri.parse(
        'https://temporary.invalid/${request.deliveryReference}',
      ),
      expiresAt: DateTime.utc(2026, 8, 30, 13),
    );
  }
}

final class _FakeDownloader implements MediaDownloadClient {
  final responses = <String, Uint8List>{};
  bool fail = false;
  int calls = 0;

  @override
  Future<Uint8List> download(EphemeralMediaUrl authorization) async {
    calls++;
    if (fail) throw StateError('transient');
    final id = authorization.value.pathSegments.last.replaceFirst(
      'opaque-reference-',
      '',
    );
    return responses[id]!;
  }
}

final class _FakeFiles implements MediaFileStore {
  _FakeFiles(this.freeBytes);

  int freeBytes;
  bool failNextWriteWithStorage = false;
  bool failDelete = false;
  int _temporary = 0;
  final paths = <String, Uint8List>{};

  @override
  Future<int> availableBytes() async => freeBytes;

  @override
  Future<void> commitTemporary({
    required String temporaryPath,
    required String path,
  }) async {
    paths[path] = paths.remove(temporaryPath)!;
  }

  @override
  Future<void> delete(String path) async {
    if (failDelete) throw StateError('delete failed');
    final removed = paths.remove(path);
    if (removed != null) freeBytes += removed.length;
  }

  @override
  Future<bool> exists(String path) async => paths.containsKey(path);

  @override
  String pathFor({
    required String ownerId,
    required String mediaId,
    required String checksumSha256,
  }) => 'cache/$mediaId-$checksumSha256';

  @override
  Future<Uint8List> read(String path) async => paths[path]!;

  @override
  Future<String> writeTemporary(Uint8List bytes) async {
    if (failNextWriteWithStorage) {
      failNextWriteWithStorage = false;
      throw const MediaStorageException();
    }
    final path = 'temporary/${_temporary++}';
    paths[path] = bytes;
    return path;
  }
}

final class _FakeNetwork implements MediaNetworkStatus {
  _FakeNetwork(this.value);
  final MediaNetwork value;

  @override
  Future<MediaNetwork> currentNetwork() async => value;
}

final class _FakeCache implements MediaCacheIndex {
  final values = <String, CachedMedia>{};

  @override
  Future<List<CachedMedia>> allVerifiedByLeastRecentAccess() async {
    final entries = values.values.toList()
      ..sort((a, b) => a.lastVerifiedAccess.compareTo(b.lastVerifiedAccess));
    return entries;
  }

  @override
  Future<CachedMedia?> find({
    required String ownerId,
    required String mediaId,
  }) async => values['$ownerId:$mediaId'];

  @override
  Future<void> put(CachedMedia media) async =>
      values['${media.ownerId}:${media.mediaId}'] = media;

  @override
  Future<void> remove({
    required String ownerId,
    required String mediaId,
  }) async => values.remove('$ownerId:$mediaId');

  @override
  Future<void> purgeOwner(String ownerId) async {
    values.removeWhere((_, media) => media.ownerId == ownerId);
  }

  @override
  Future<void> touch({
    required String ownerId,
    required String mediaId,
    required DateTime at,
  }) async {
    final key = '$ownerId:$mediaId';
    final existing = values[key]!;
    values[key] = CachedMedia(
      ownerId: existing.ownerId,
      mediaId: existing.mediaId,
      path: existing.path,
      version: existing.version,
      checksumSha256: existing.checksumSha256,
      requiredEntitlement: existing.requiredEntitlement,
      byteSize: existing.byteSize,
      lastVerifiedAccess: at,
    );
  }
}
