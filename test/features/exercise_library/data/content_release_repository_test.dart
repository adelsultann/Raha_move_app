import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';

import 'release_fixture.dart';

void main() {
  late AppDatabase database;
  late ContentReleaseRepository repository;
  final appliedAt = DateTime.utc(2026, 8, 29, 12);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ContentReleaseRepository(database, clock: () => appliedAt);
  });

  tearDown(() => database.close());

  Future<void> expectThrowsWithCode(
    Future<void> Function() action,
    String code,
  ) async {
    await expectLater(
      action,
      throwsA(
        isA<ContentReleaseException>().having((e) => e.code, 'code', code),
      ),
    );
  }

  test('applies a valid release atomically and marks it current', () async {
    await repository.applyRelease(
      envelopeFor(minimalValidManifest()),
      appVersion: '1.0.0',
    );

    expect(await repository.currentReleaseId(), '1');
    expect(await database.select(database.localExercises).get(), hasLength(1));
    expect(await database.select(database.localRoutines).get(), hasLength(1));
    expect(
      await database.select(database.localMediaAssets).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.localRoutineSteps).get(),
      hasLength(1),
    );
    expect(await database.select(database.localTaxonomies).get(), hasLength(5));
    expect(
      await database.select(database.localExerciseTranslations).get(),
      hasLength(2),
    );

    final routines = await LocalContentRepository(database)
        .watchPublishedRoutines()
        .first;
    expect(routines.single.id, 'raha_rt_000001');
  });

  test('rejects a checksum mismatch without applying anything', () async {
    await expectThrowsWithCode(
      () => repository.applyRelease(
        envelopeFor(minimalValidManifest(), overrideChecksum: '0' * 64),
        appVersion: '1.0.0',
      ),
      'checksum_mismatch',
    );
    expect(await repository.currentReleaseId(), isNull);
    expect(await database.select(database.localExercises).get(), isEmpty);
  });

  test('rejects a release that is not newer than the current one', () async {
    await repository.applyRelease(
      envelopeFor(minimalValidManifest()),
      appVersion: '1.0.0',
    );

    // Same sequence id must be rejected.
    await expectThrowsWithCode(
      () => repository.applyRelease(
        envelopeFor(minimalValidManifest()),
        appVersion: '1.0.0',
      ),
      'release_continuity',
    );

    // An older sequence id must also be rejected.
    await expectThrowsWithCode(
      () => repository.applyRelease(
        envelopeFor(
          minimalValidManifest(releaseId: '0', releaseVersion: 'old'),
        ),
        appVersion: '1.0.0',
      ),
      'release_continuity',
    );
  });

  test('rejects a release requiring a newer app version', () async {
    final manifest = minimalValidManifest();
    (manifest['release'] as Map<String, dynamic>)['minimum_app_version'] =
        '2.0.0';
    await expectThrowsWithCode(
      () => repository.applyRelease(envelopeFor(manifest), appVersion: '1.0.0'),
      'incompatible_app_version',
    );
    expect(await repository.currentReleaseId(), isNull);
  });

  test(
    'rejects a corrupt release and keeps the prior catalog current',
    () async {
      await repository.applyRelease(
        envelopeFor(minimalValidManifest()),
        appVersion: '1.0.0',
      );

      // A release whose step references an unknown exercise is structurally
      // corrupt but has a valid checksum (computed over the corrupt document).
      final corrupt = minimalValidManifest(
        releaseId: '2',
        releaseVersion: 'r2',
      );
      final steps = (corrupt['routine_steps'] as List)
          .cast<Map<String, dynamic>>();
      steps.single['exercise_id'] = '99999999-0000-0000-0000-000000000000';

      await expectThrowsWithCode(
        () =>
            repository.applyRelease(envelopeFor(corrupt), appVersion: '1.0.0'),
        'unknown_exercise',
      );

      expect(await repository.currentReleaseId(), '1');
      final routines = await LocalContentRepository(database)
          .watchPublishedRoutines()
          .first;
      expect(routines.single.id, 'raha_rt_000001');
    },
  );

  test('retires removed content but preserves it for history', () async {
    final first = minimalValidManifest();
    await repository.applyRelease(envelopeFor(first), appVersion: '1.0.0');

    // Second release drops the only exercise/routine and tombstones the media.
    final second = minimalValidManifest(releaseId: '2', releaseVersion: 'r2');
    second['exercises'] = <Object>[];
    second['exercise_translations'] = <Object>[];
    second['media_assets'] = <Object>[];
    second['routines'] = <Object>[];
    second['routine_translations'] = <Object>[];
    second['routine_steps'] = <Object>[];
    second['exercise_body_areas'] = <Object>[];
    second['exercise_positions'] = <Object>[];
    second['exercise_equipment'] = <Object>[];
    second['exercise_goals'] = <Object>[];
    second['routine_body_areas'] = <Object>[];
    second['routine_goals'] = <Object>[];
    second['routine_positions'] = <Object>[];
    second['routine_context_memberships'] = <Object>[];
    second['routine_equipment'] = <Object>[];

    await repository.applyRelease(envelopeFor(second), appVersion: '1.0.0');

    expect(await repository.currentReleaseId(), '2');

    // Retired rows are preserved (not deleted) but no longer published.
    final exercise = await (database.select(
      database.localExercises,
    )..where((r) => r.id.equals('raha_ex_000001'))).getSingle();
    final routine = await (database.select(
      database.localRoutines,
    )..where((r) => r.id.equals('raha_rt_000001'))).getSingle();
    final step = await (database.select(
      database.localRoutineSteps,
    )..where((r) => r.routineId.equals('raha_rt_000001'))).getSingle();

    expect(exercise.status, 'retired');
    expect(routine.status, 'retired');
    expect(step.status, 'retired');

    expect(
      await LocalContentRepository(database).watchPublishedRoutines().first,
      isEmpty,
    );
  });

  test('applies an explicit tombstone using its entity public id', () async {
    final first = minimalValidManifest();
    await repository.applyRelease(envelopeFor(first), appVersion: '1.0.0');

    // Keep the routine published but tombstone it by its stable public id.
    final second = minimalValidManifest(releaseId: '2', releaseVersion: 'r2');
    second['tombstones'] = [
      {
        'entity_type': 'routine',
        'entity_public_id': 'raha_rt_000001',
        'entity_id': '03000000-0000-0000-0000-000000000001',
        'retired_at': '2026-08-29T00:00:00Z',
      },
    ];

    await repository.applyRelease(envelopeFor(second), appVersion: '1.0.0');

    final routine = await (database.select(
      database.localRoutines,
    )..where((r) => r.id.equals('raha_rt_000001'))).getSingle();
    expect(routine.status, 'retired');
    expect(
      await LocalContentRepository(database).watchPublishedRoutines().first,
      isEmpty,
    );
  });

  test('rejects an exercise without literal true safety approval', () async {
    final manifest = minimalValidManifest();
    (manifest['exercises'] as List).cast<Map<String, dynamic>>().single.remove(
      'safety_approved',
    );
    await expectThrowsWithCode(
      () => repository.applyRelease(envelopeFor(manifest), appVersion: '1.0.0'),
      'not_safety_approved',
    );
    expect(await repository.currentReleaseId(), isNull);
  });

  test('rejects a routine with a falsy safety approval value', () async {
    final manifest = minimalValidManifest();
    (manifest['routines'] as List)
            .cast<Map<String, dynamic>>()
            .single['safety_approved'] =
        false;
    await expectThrowsWithCode(
      () => repository.applyRelease(envelopeFor(manifest), appVersion: '1.0.0'),
      'not_safety_approved',
    );
  });

  test('rejects a taxonomy missing a bilingual label', () async {
    final manifest = minimalValidManifest();
    // Drop the Arabic body-area label.
    manifest['body_area_translations'] = [
      {
        'body_area_id': '41000000-0000-0000-0000-000000000001',
        'locale': 'en',
        'name': 'Neck',
      },
    ];
    await expectThrowsWithCode(
      () => repository.applyRelease(envelopeFor(manifest), appVersion: '1.0.0'),
      'missing_translation',
    );
  });

  test(
    'rejects published media without a checksum and pending media with one',
    () async {
      final noChecksum = minimalValidManifest();
      (noChecksum['media_assets'] as List)
          .cast<Map<String, dynamic>>()
          .single
          .remove('checksum_sha256');
      await expectThrowsWithCode(
        () => repository.applyRelease(
          envelopeFor(noChecksum),
          appVersion: '1.0.0',
        ),
        'invalid_media_checksum',
      );

      final pendingWithChecksum = minimalValidManifest();
      (pendingWithChecksum['media_assets'] as List)
          .cast<Map<String, dynamic>>()
          .single
        ..['status'] = 'pending'
        ..['checksum_sha256'] =
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      await expectThrowsWithCode(
        () => repository.applyRelease(
          envelopeFor(pendingWithChecksum),
          appVersion: '1.0.0',
        ),
        'invalid_media_checksum',
      );
    },
  );

  test('bootstraps the bundled starter catalog before any sync', () async {
    final raw = File('assets/starter_content/manifests/starter_catalog.json')
        .readAsStringSync();
    final starter = BundledStarterContent(loadString: (path) async => raw);
    final envelope = await starter.load();

    expect(envelope.releaseId, '0');
    expect(
      envelope.manifest.mediaAssets.every((m) => m.checksumSha256 == null),
      isTrue,
      reason: 'Starter media must be designated pending, not invented',
    );
    expect(
      envelope.manifest.mediaAssets.every((m) => m.status == 'pending'),
      isTrue,
    );
    await repository.applyRelease(envelope, appVersion: '1.0.0');

    expect(await repository.currentReleaseId(), '0');
    final routines = await LocalContentRepository(database)
        .watchPublishedRoutines()
        .first;
    expect(routines.single.id, 'raha_rt_000001');
    expect(
      await database.select(database.localExerciseTranslations).get(),
      hasLength(4),
    );

    // Pending media is persisted as pending with an empty checksum so it is
    // never mistaken for delivered, playable content.
    final media = await database.select(database.localMediaAssets).get();
    expect(media.every((m) => m.status == 'pending'), isTrue);
    expect(media.every((m) => m.checksumSha256.isEmpty), isTrue);
  });

  test(
    'populates remote id mappings atomically with a valid release',
    () async {
      await repository.applyRelease(
        envelopeFor(minimalValidManifest()),
        appVersion: '1.0.0',
      );

      final mappings = await database.select(database.localIdMappings).get();
      // 1 exercise + 1 routine + 5 taxonomies (body_area, goal, position,
      // equipment, context).
      expect(mappings, hasLength(7));

      String? remoteFor(String kind, String localId) {
        for (final m in mappings) {
          if (m.kind == kind && m.localId == localId) return m.remoteId;
        }
        return null;
      }

      expect(
        remoteFor(RemoteIdMappingKind.exercise, 'raha_ex_000001'),
        '01000000-0000-0000-0000-000000000001',
      );
      expect(
        remoteFor(RemoteIdMappingKind.routine, 'raha_rt_000001'),
        '03000000-0000-0000-0000-000000000001',
      );
      expect(
        remoteFor(RemoteIdMappingKind.taxonomy, 'neck'),
        '41000000-0000-0000-0000-000000000001',
      );
      expect(
        remoteFor(RemoteIdMappingKind.taxonomy, 'ease_stiffness'),
        '42000000-0000-0000-0000-000000000001',
      );
    },
  );

  test('mappings roll back together when a release fails to apply', () async {
    await repository.applyRelease(
      envelopeFor(minimalValidManifest()),
      appVersion: '1.0.0',
    );
    final snapshot = (await database.select(database.localIdMappings).get())
        .map((m) => '${m.kind}|${m.localId}|${m.remoteId}')
        .toSet();

    // A structurally corrupt release fails during validation, so no mapping
    // write from it may leak into the local cache.
    final corrupt = minimalValidManifest(releaseId: '2', releaseVersion: 'r2');
    (corrupt['routine_steps'] as List)
            .cast<Map<String, dynamic>>()
            .single['exercise_id'] =
        '99999999-0000-0000-0000-000000000000';

    await expectThrowsWithCode(
      () => repository.applyRelease(envelopeFor(corrupt), appVersion: '1.0.0'),
      'unknown_exercise',
    );

    final after = (await database.select(database.localIdMappings).get())
        .map((m) => '${m.kind}|${m.localId}|${m.remoteId}')
        .toSet();
    expect(after, snapshot);
    expect(await repository.currentReleaseId(), '1');
  });
}
