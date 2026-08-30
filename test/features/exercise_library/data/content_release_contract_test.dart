import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/semantic_version.dart';

import 'release_fixture.dart';

void main() {
  group('SemanticVersion', () {
    test('parses and compares MAJOR.MINOR.PATCH', () {
      expect(
        SemanticVersion.parse('1.0.0')
            .compareTo(SemanticVersion.parse('1.1.0')),
        lessThan(0),
      );
      expect(
        SemanticVersion.parse('1.0.0')
            .compareTo(SemanticVersion.parse('1.0.1')),
        lessThan(0),
      );
      expect(
        SemanticVersion.parse('2.0.0')
            .compareTo(SemanticVersion.parse('1.9.9')),
        greaterThan(0),
      );
      expect(
        SemanticVersion.parse('1.0.0')
            .compareTo(SemanticVersion.parse('1.0.0')),
        0,
      );
    });

    test('rejects malformed versions', () {
      for (final value in ['1.0', '1', 'a.b.c', '1.0.x', '1.0.0.0', '']) {
        expect(SemanticVersion.tryParse(value), isNull, reason: value);
      }
    });
  });

  group('ContentReleaseManifest', () {
    test('normalizes taxonomies and assignments and builds lookup maps', () {
      final manifest = ContentReleaseManifest.fromJson(minimalValidManifest());

      expect(manifest.contractVersion, 'raha-content-release-v1');
      expect(manifest.release.id, '1');
      expect(manifest.exercises.single.publicId, 'raha_ex_000001');
      expect(manifest.exercises.single.safetyApproved, isTrue);
      expect(manifest.routines.single.publicId, 'raha_rt_000001');
      expect(manifest.routines.single.safetyApproved, isTrue);
      expect(
        manifest.mediaAssets.single.deliveryReference,
        isNot(contains('://')),
      );

      expect(manifest.taxonomies.map((t) => t.kind).toSet(), {
        'body_area',
        'goal',
        'position',
        'equipment',
        'context',
      });
      expect(
        manifest.taxonomies.singleWhere((t) => t.kind == 'body_area').labels,
        {'en': 'Neck', 'ar': 'الرقبة'},
      );

      expect(
        manifest.exercisePublicIdByUuid['01000000-0000-0000-0000-000000000001'],
        'raha_ex_000001',
      );
      expect(
        manifest.routinePublicIdByUuid['03000000-0000-0000-0000-000000000001'],
        'raha_rt_000001',
      );
      expect(
        manifest.taxonomyKeyByUuid['41000000-0000-0000-0000-000000000001'],
        'neck',
      );

      expect(manifest.exerciseTaxonomies, isNotEmpty);
      expect(manifest.routineTaxonomies, isNotEmpty);
      expect(manifest.tombstones, isEmpty);
    });

    test('parses tombstones with an entity public id', () {
      final map = minimalValidManifest()
        ..['tombstones'] = [
          {
            'entity_type': 'exercise',
            'entity_public_id': 'raha_ex_000001',
            'entity_id': '01000000-0000-0000-0000-000000000001',
            'retired_at': '2026-08-29T00:00:00Z',
          },
        ];
      final manifest = ContentReleaseManifest.fromJson(map);
      expect(manifest.tombstones.single.entityType, 'exercise');
      expect(manifest.tombstones.single.entityPublicId, 'raha_ex_000001');
      expect(
        manifest.tombstones.single.entityId,
        '01000000-0000-0000-0000-000000000001',
      );
    });
  });

  group('buildContentReleaseEnvelope', () {
    test('verifies the canonical checksum and derives release metadata', () {
      final envelope = envelopeFor(minimalValidManifest());

      expect(envelope.releaseId, '1');
      expect(envelope.version, 'release-1');
      expect(envelope.minimumAppVersion, '1.0.0');
      expect(
        canonicalManifestChecksum(envelope.canonicalManifestBytes),
        envelope.manifestChecksum,
      );
    });

    test('rejects a mismatched checksum', () {
      final manifest = minimalValidManifest();
      expect(
        () => envelopeFor(manifest, overrideChecksum: '0' * 64),
        throwsA(
          isA<ContentReleaseException>().having(
            (e) => e.code,
            'code',
            'checksum_mismatch',
          ),
        ),
      );
    });

    test('rejects a non-object payload', () {
      expect(
        () => decodeContentReleaseEnvelope('[]'),
        throwsA(isA<ContentReleaseException>()),
      );
      expect(
        () => decodeContentReleaseEnvelope('not json'),
        throwsA(isA<ContentReleaseException>()),
      );
    });
  });
}
