import 'dart:convert';
import 'dart:io';

import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';

/// Builds a verified [ContentReleaseEnvelope] for [manifest], computing the
/// canonical checksum automatically so tests exercise the same checksum path a
/// production source would.
ContentReleaseEnvelope envelopeFor(
  Map<String, dynamic> manifest, {
  String? overrideChecksum,
}) {
  final bytes = CanonicalJson.encodeBytes(manifest);
  return buildContentReleaseEnvelope({
    'manifest_checksum': overrideChecksum ?? canonicalManifestChecksum(bytes),
    'manifest': manifest,
  });
}

/// A deep copy of [value] so tests can mutate one branch safely.
Map<String, dynamic> deepCopy(Object? value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

/// The bundled starter catalog's `manifest` object, decoded from the asset so
/// the repository tests exercise the real seed data.
Map<String, dynamic> bundledStarterManifest() => deepCopy(
  jsonDecode(
    File('assets/starter_content/manifests/starter_catalog.json')
        .readAsStringSync(),
  )['manifest'],
);

/// A minimal but fully valid manifest: one exercise, one routine, one timed
/// step, one preferred playable media asset, and the taxonomies the joins need.
Map<String, dynamic> minimalValidManifest({
  String releaseId = '1',
  String releaseVersion = 'release-1',
}) {
  const exerciseUuid = '01000000-0000-0000-0000-000000000001';
  const mediaUuid = '02000000-0000-0000-0000-000000000001';
  const routineUuid = '03000000-0000-0000-0000-000000000001';
  const stepUuid = '04000000-0000-0000-0000-000000000001';
  const bodyAreaUuid = '41000000-0000-0000-0000-000000000001';
  const goalUuid = '42000000-0000-0000-0000-000000000001';
  const positionUuid = '43000000-0000-0000-0000-000000000001';
  const equipmentUuid = '44000000-0000-0000-0000-000000000001';
  const contextUuid = '45000000-0000-0000-0000-000000000001';

  return {
    'contract_version': 'raha-content-release-v1',
    'release': {
      'id': releaseId,
      'version': releaseVersion,
      'published_at': '2026-08-29T00:00:00Z',
      'minimum_app_version': '1.0.0',
    },
    'exercises': [
      {
        'id': exerciseUuid,
        'public_id': 'raha_ex_000001',
        'status': 'published',
        'access_tier': 'free',
        'difficulty': 'beginner',
        'safety_approved': true,
        'updated_at': '2026-08-29T00:00:00Z',
      },
    ],
    'exercise_translations': [
      {
        'exercise_id': exerciseUuid,
        'locale': 'en',
        'name': 'Seated neck release',
        'description': 'A gentle seated neck stretch.',
      },
      {
        'exercise_id': exerciseUuid,
        'locale': 'ar',
        'name': 'تحرير الرقبة أثناء الجلوس',
        'description': 'تمدد لطيف للرقبة أثناء الجلوس.',
      },
    ],
    'media_assets': [
      {
        'id': mediaUuid,
        'exercise_id': exerciseUuid,
        'delivery_reference': '0a000000-0000-0000-0000-000000000001',
        'status': 'published',
        'media_type': 'video',
        'mime_type': 'video/mp4',
        'width': 720,
        'height': 720,
        'duration_ms': 30000,
        'checksum_sha256':
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'is_preferred': true,
        'updated_at': '2026-08-29T00:00:00Z',
      },
    ],
    'routines': [
      {
        'id': routineUuid,
        'public_id': 'raha_rt_000001',
        'status': 'published',
        'access_tier': 'free',
        'difficulty': 'beginner',
        'safety_approved': true,
        'estimated_duration_seconds': 30,
        'version': 1,
        'updated_at': '2026-08-29T00:00:00Z',
      },
    ],
    'routine_translations': [
      {
        'routine_id': routineUuid,
        'locale': 'en',
        'name': 'Seated neck reset',
        'summary': 'A short seated mobility routine.',
      },
      {
        'routine_id': routineUuid,
        'locale': 'ar',
        'name': 'استراحة للرقبة أثناء الجلوس',
        'summary': 'روتين حركة قصير أثناء الجلوس.',
      },
    ],
    'routine_steps': [
      {
        'id': stepUuid,
        'routine_id': routineUuid,
        'exercise_id': exerciseUuid,
        'position': 1,
        'duration_seconds': 30,
        'rest_after_seconds': 0,
        'is_optional': false,
      },
    ],
    'body_areas': [
      {'id': bodyAreaUuid, 'key': 'neck', 'sort_order': 1, 'active': true},
    ],
    'body_area_translations': [
      {'body_area_id': bodyAreaUuid, 'locale': 'en', 'name': 'Neck'},
      {'body_area_id': bodyAreaUuid, 'locale': 'ar', 'name': 'الرقبة'},
    ],
    'goals': [
      {
        'id': goalUuid,
        'key': 'ease_stiffness',
        'sort_order': 1,
        'active': true,
      },
    ],
    'goal_translations': [
      {'goal_id': goalUuid, 'locale': 'en', 'name': 'Ease stiffness'},
      {'goal_id': goalUuid, 'locale': 'ar', 'name': 'تخفيف التيبس'},
    ],
    'movement_positions': [
      {'id': positionUuid, 'key': 'seated', 'sort_order': 1, 'active': true},
    ],
    'movement_position_translations': [
      {'position_id': positionUuid, 'locale': 'en', 'name': 'Seated'},
      {'position_id': positionUuid, 'locale': 'ar', 'name': 'جلوس'},
    ],
    'equipment': [
      {
        'id': equipmentUuid,
        'key': 'body_weight',
        'sort_order': 1,
        'active': true,
      },
    ],
    'equipment_translations': [
      {'equipment_id': equipmentUuid, 'locale': 'en', 'name': 'Body weight'},
      {'equipment_id': equipmentUuid, 'locale': 'ar', 'name': 'وزن الجسم'},
    ],
    'routine_contexts': [
      {
        'id': contextUuid,
        'key': 'everyday_mobility',
        'sort_order': 1,
        'active': true,
      },
    ],
    'routine_context_translations': [
      {'context_id': contextUuid, 'locale': 'en', 'name': 'Everyday mobility'},
      {'context_id': contextUuid, 'locale': 'ar', 'name': 'حركة يومية'},
    ],
    'tags': <Object>[],
    'tag_translations': <Object>[],
    'exercise_body_areas': [
      {
        'exercise_id': exerciseUuid,
        'body_area_id': bodyAreaUuid,
        'relevance_weight': 1.0,
      },
    ],
    'exercise_positions': [
      {'exercise_id': exerciseUuid, 'position_id': positionUuid},
    ],
    'exercise_equipment': [
      {'exercise_id': exerciseUuid, 'equipment_id': equipmentUuid},
    ],
    'exercise_goals': [
      {'exercise_id': exerciseUuid, 'goal_id': goalUuid},
    ],
    'exercise_tags': <Object>[],
    'routine_body_areas': [
      {
        'routine_id': routineUuid,
        'body_area_id': bodyAreaUuid,
        'relevance_weight': 1.0,
      },
    ],
    'routine_goals': [
      {'routine_id': routineUuid, 'goal_id': goalUuid, 'relevance_weight': 1.0},
    ],
    'routine_positions': [
      {'routine_id': routineUuid, 'position_id': positionUuid},
    ],
    'routine_context_memberships': [
      {'routine_id': routineUuid, 'context_id': contextUuid},
    ],
    'routine_equipment': [
      {'routine_id': routineUuid, 'equipment_id': equipmentUuid},
    ],
    'tombstones': <Object>[],
  };
}
