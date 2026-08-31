import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:raha_move/features/recommendations/application/readiness_providers.dart';
import 'package:raha_move/features/recommendations/application/routine_readiness_controller.dart';
import 'package:raha_move/features/recommendations/domain/routine_readiness.dart';

void main() {
  const checksum =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  MediaDelivery delivery(String id) => MediaDelivery(
    mediaId: id,
    deliveryReference: 'ref-$id',
    version: 'v1',
    checksumSha256: checksum,
  );

  test(
    'returns ready with ordered prepared media when preparation succeeds',
    () async {
      final container = _container(
        resolution: RoutineMediaResolution(
          media: [delivery('m1'), delivery('m2')],
          missingExerciseIds: const [],
        ),
        preparer: _FakePreparer(
          RoutineMediaPreparation({
            'm1': const MediaPrepared(
              mediaId: 'm1',
              localPath: 'cache/m1',
              fromCache: true,
            ),
            'm2': const MediaPrepared(
              mediaId: 'm2',
              localPath: 'cache/m2',
              fromCache: false,
            ),
          }),
        ),
      );
      addTearDown(container.dispose);

      final readiness = await container
          .read(routineReadinessControllerProvider('rt-1').notifier)
          .start();

      expect(readiness.isReady, isTrue);
      expect(readiness.preparedMedia.map((m) => m.mediaId), ['m1', 'm2']);
      expect(
        container.read(routineReadinessControllerProvider('rt-1')).phase,
        RoutineReadinessPhase.done,
      );
    },
  );

  test('reports missing media when a step has no playable asset', () async {
    final container = _container(
      resolution: const RoutineMediaResolution(
        media: [],
        missingExerciseIds: ['ex-missing'],
      ),
    );
    addTearDown(container.dispose);

    final readiness = await container
        .read(routineReadinessControllerProvider('rt-1').notifier)
        .start();

    expect(readiness.status, RoutineReadinessStatus.missingMedia);
    expect(readiness.missingExerciseCount, 1);
  });

  test('surfaces an unavailable result with its failure code', () async {
    final container = _container(
      resolution: RoutineMediaResolution(
        media: [delivery('m1')],
        missingExerciseIds: const [],
      ),
      preparer: _FakePreparer(
        RoutineMediaPreparation({
          'm1': const MediaUnavailable(
            mediaId: 'm1',
            code: MediaFailureCode.downloadFailed,
            canRetry: true,
          ),
        }),
      ),
    );
    addTearDown(container.dispose);

    final readiness = await container
        .read(routineReadinessControllerProvider('rt-1').notifier)
        .start();

    expect(readiness.status, RoutineReadinessStatus.unavailable);
    expect(readiness.failureCode, MediaFailureCode.downloadFailed);
    expect(readiness.canRetry, isTrue);
  });

  test(
    'surfaces a storage-needed result when the device is out of space',
    () async {
      final container = _container(
        resolution: RoutineMediaResolution(
          media: [delivery('m1')],
          missingExerciseIds: const [],
        ),
        preparer: _FakePreparer(
          RoutineMediaPreparation({
            'm1': const MediaStorageNeeded(mediaId: 'm1', requiredBytes: 4096),
          }),
        ),
      );
      addTearDown(container.dispose);

      final readiness = await container
          .read(routineReadinessControllerProvider('rt-1').notifier)
          .start();

      expect(readiness.status, RoutineReadinessStatus.storageNeeded);
      expect(readiness.requiredBytes, 4096);
    },
  );

  test('reports offline when there is no media access scope', () async {
    final container = _container(
      resolution: RoutineMediaResolution(
        media: [delivery('m1')],
        missingExerciseIds: const [],
      ),
      preparer: null,
    );
    addTearDown(container.dispose);

    final readiness = await container
        .read(routineReadinessControllerProvider('rt-1').notifier)
        .start();

    expect(readiness.status, RoutineReadinessStatus.unavailable);
    expect(readiness.failureCode, MediaFailureCode.offline);
  });
}

ProviderContainer _container({
  required RoutineMediaResolution resolution,
  RoutineMediaPreparer? preparer,
}) {
  return ProviderContainer(
    overrides: [
      routineMediaResolverProvider.overrideWithValue(_FakeResolver(resolution)),
      routineMediaPreparerProvider.overrideWith((ref) async => preparer),
    ],
  );
}

final class _FakeResolver implements RoutineMediaResolver {
  _FakeResolver(this.resolution);

  final RoutineMediaResolution resolution;

  @override
  Future<RoutineMediaResolution> resolve(String routineId) async => resolution;
}

final class _FakePreparer implements RoutineMediaPreparer {
  _FakePreparer(this.preparation);

  final RoutineMediaPreparation preparation;

  @override
  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> media, {
    required bool explicitUserStart,
  }) async => preparation;
}
