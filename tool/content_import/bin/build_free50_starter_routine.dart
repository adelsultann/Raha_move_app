import 'dart:convert';
import 'dart:io';

import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';

const _manifestPath = 'assets/starter_content/manifests/starter_catalog.json';
const _publishedAt = '2026-10-01T00:00:00Z';
const _routineId = '03000000-0000-0000-0000-000000000002';

const _bodyAreas = {
  'shoulders': '41000000-0000-0000-0000-000000000002',
  'upper_back': '41000000-0000-0000-0000-000000000003',
  'lower_back': '41000000-0000-0000-0000-000000000004',
  'hips': '41000000-0000-0000-0000-000000000005',
  'full_body': '41000000-0000-0000-0000-000000000007',
};
const _positions = {
  'seated': '43000000-0000-0000-0000-000000000001',
  'standing': '43000000-0000-0000-0000-000000000002',
  'floor': '43000000-0000-0000-0000-000000000003',
};
const _equipmentId = '44000000-0000-0000-0000-000000000001';
const _contextId = '45000000-0000-0000-0000-000000000001';
const _easeStiffnessId = '42000000-0000-0000-0000-000000000001';
const _moveFreelyId = '42000000-0000-0000-0000-000000000002';
const _relaxId = '42000000-0000-0000-0000-000000000004';

final _exercises = <_ExerciseFixture>[
  const _ExerciseFixture(
    number: 101,
    nameEn: 'Shoulder blade elevation and depression',
    nameAr: 'رفع وخفض لوحي الكتف',
    descriptionEn: 'A controlled standing movement for the shoulder blades.',
    descriptionAr: 'حركة وقوف متحكم بها للوحَي الكتف.',
    cueEn: 'Move slowly and keep your neck relaxed.',
    cueAr: 'تحرّك ببطء وحافظ على استرخاء الرقبة.',
    areas: ['shoulders', 'upper_back'],
    position: 'standing',
    durationMs: 1811,
    checksum:
        '0e146ee8d59fbd30dbf335f2f21172d6e39906576139167d6ba1ede0180908c9',
  ),
  const _ExerciseFixture(
    number: 102,
    nameEn: 'Cross-body shoulder stretch',
    nameAr: 'تمدد الكتف عبر الجسم',
    descriptionEn: 'A gentle standing stretch across the back of the shoulder.',
    descriptionAr: 'تمدد لطيف أثناء الوقوف للجزء الخلفي من الكتف.',
    cueEn: 'Keep the shoulder down and use a comfortable range.',
    cueAr: 'أبقِ الكتف منخفضاً وتحرك ضمن مدى مريح.',
    areas: ['shoulders'],
    position: 'standing',
    durationMs: 5480,
    checksum:
        'cc6a9c8d00264497cb69bc5ba80f904e47a9ccd5aab23baae6a4cf9a878a510f',
  ),
  const _ExerciseFixture(
    number: 103,
    nameEn: 'Standing reach and back rotation',
    nameAr: 'مدّ الذراع ودوران الظهر أثناء الوقوف',
    descriptionEn: 'A standing reach with a controlled upper-back rotation.',
    descriptionAr: 'مدّ للذراع مع دوران متحكم به لأعلى الظهر أثناء الوقوف.',
    cueEn: 'Rotate gently without forcing the movement.',
    cueAr: 'أدر جسمك بلطف من دون إجبار الحركة.',
    areas: ['upper_back', 'shoulders'],
    position: 'standing',
    durationMs: 4667,
    checksum:
        'c10a58cb151f5a5ff78e0ccbd30395ecfbbf6cd6aa66822b6b665284ea3c84f1',
  ),
  const _ExerciseFixture(
    number: 104,
    nameEn: 'Standing side stretch',
    nameAr: 'تمدد جانبي أثناء الوقوف',
    descriptionEn: 'A gentle standing side bend for whole-body mobility.',
    descriptionAr: 'انحناء جانبي لطيف أثناء الوقوف لدعم حركة الجسم.',
    cueEn: 'Reach upward before bending to the side.',
    cueAr: 'مدّ جسمك للأعلى قبل الانحناء جانباً.',
    areas: ['upper_back', 'full_body'],
    position: 'standing',
    durationMs: 4342,
    checksum:
        'c210d9eca171243063705b5a8e3e28cdcfe034069a4b1ca760ac22bcd358fdfe',
  ),
  const _ExerciseFixture(
    number: 105,
    nameEn: 'Hip circles',
    nameAr: 'دوائر الورك',
    descriptionEn: 'Controlled standing circles for gentle hip mobility.',
    descriptionAr: 'دوائر متحكم بها أثناء الوقوف لدعم حركة الورك بلطف.',
    cueEn: 'Keep the circles smooth and comfortable.',
    cueAr: 'اجعل الدوائر انسيابية ومريحة.',
    areas: ['hips'],
    position: 'standing',
    durationMs: 11772,
    checksum:
        '59339ad55ac4e037e4f1987b86c1ee84e8f237a3397fb62c5161a555b953f9b6',
  ),
  const _ExerciseFixture(
    number: 106,
    nameEn: 'Standing pelvic tilt',
    nameAr: 'إمالة الحوض أثناء الوقوف',
    descriptionEn: 'A small standing pelvic movement for lower-body awareness.',
    descriptionAr: 'حركة صغيرة للحوض أثناء الوقوف لتعزيز الوعي بالحركة.',
    cueEn: 'Use a small range and keep breathing normally.',
    cueAr: 'استخدم مدى صغيراً واستمر في التنفس بشكل طبيعي.',
    areas: ['hips', 'lower_back'],
    position: 'standing',
    durationMs: 9079,
    checksum:
        '2012b9ffe5c5c63beae65025686889bc962d38a6e8b33d15c3864df3dbe462d3',
  ),
  const _ExerciseFixture(
    number: 107,
    nameEn: 'Standing hamstring and back stretch',
    nameAr: 'تمدد أوتار الركبة والظهر أثناء الوقوف',
    descriptionEn: 'A supported standing stretch for the back and legs.',
    descriptionAr: 'تمدد مدعوم أثناء الوقوف للظهر والساقين.',
    cueEn: 'Soften your knees and stop before discomfort.',
    cueAr: 'أرخِ ركبتيك وتوقف قبل الشعور بعدم الارتياح.',
    areas: ['lower_back', 'hips'],
    position: 'standing',
    durationMs: 11076,
    checksum:
        'ff3cddd7db8c512294e8d0e96ce5e053dce4a52a14d706fa7de5ff24cca0f0a7',
  ),
  const _ExerciseFixture(
    number: 108,
    nameEn: 'Kneeling hip flexor stretch',
    nameAr: 'تمدد مثنيات الورك من وضع الركوع',
    descriptionEn: 'A gentle kneeling stretch for the front of the hip.',
    descriptionAr: 'تمدد لطيف من وضع الركوع لمقدمة الورك.',
    cueEn: 'Keep your torso tall and move forward gently.',
    cueAr: 'حافظ على استقامة الجذع وتحرك للأمام بلطف.',
    areas: ['hips'],
    position: 'floor',
    durationMs: 3274,
    checksum:
        '4984907e62eaeca167c41585fa583fdd720fbaece057883c6261f7069a17730e',
  ),
  const _ExerciseFixture(
    number: 109,
    nameEn: 'Seated cat-cow stretch',
    nameAr: 'تمدد القطة والبقرة أثناء الجلوس',
    descriptionEn:
        'A seated spinal movement that alternates rounding and opening.',
    descriptionAr:
        'حركة للعمود الفقري أثناء الجلوس بالتناوب بين التقوس والانفتاح.',
    cueEn: 'Match the movement to an easy breath.',
    cueAr: 'نسّق الحركة مع تنفس مريح.',
    areas: ['upper_back', 'lower_back'],
    position: 'seated',
    durationMs: 2809,
    checksum:
        '33e06e288881e7d74663bfbd269523077b25e89426a1ed759173100d999be7a0',
  ),
  const _ExerciseFixture(
    number: 110,
    nameEn: 'Supine windshield wipers',
    nameAr: 'مسّاحات الركبتين أثناء الاستلقاء',
    descriptionEn: 'A relaxed side-to-side knee movement while lying down.',
    descriptionAr: 'حركة مريحة للركبتين من جانب إلى آخر أثناء الاستلقاء.',
    cueEn: 'Let the knees move only as far as feels comfortable.',
    cueAr: 'حرّك ركبتيك فقط ضمن المدى المريح.',
    areas: ['hips', 'lower_back'],
    position: 'floor',
    durationMs: 4342,
    checksum:
        'f8530ebad427d89fd8b2f368522a67c83a4749add1aa1fa319adc7a0f880464f',
  ),
];

void main() {
  final file = File(_manifestPath);
  final envelope = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final manifest = envelope['manifest'] as Map<String, dynamic>;

  manifest['release'] = {
    'id': '1',
    'version': 'starter-2',
    'published_at': _publishedAt,
    'minimum_app_version': '1.0.0',
  };

  _replace(manifest, 'exercises', _exerciseIds, [
    for (final exercise in _exercises) exercise.exercise,
  ]);
  _replaceByForeignKey(
    manifest,
    'exercise_translations',
    'exercise_id',
    _exerciseIds,
    [for (final exercise in _exercises) ...exercise.translations],
  );
  _replaceByForeignKey(manifest, 'media_assets', 'exercise_id', _exerciseIds, [
    for (final exercise in _exercises) exercise.media,
  ]);
  _replaceByForeignKey(
    manifest,
    'exercise_body_areas',
    'exercise_id',
    _exerciseIds,
    [for (final exercise in _exercises) ...exercise.bodyAreaAssignments],
  );
  _replaceByForeignKey(
    manifest,
    'exercise_positions',
    'exercise_id',
    _exerciseIds,
    [for (final exercise in _exercises) exercise.positionAssignment],
  );
  _replaceByForeignKey(
    manifest,
    'exercise_equipment',
    'exercise_id',
    _exerciseIds,
    [for (final exercise in _exercises) exercise.equipmentAssignment],
  );
  _replaceByForeignKey(
    manifest,
    'exercise_goals',
    'exercise_id',
    _exerciseIds,
    [for (final exercise in _exercises) ...exercise.goalAssignments],
  );

  _replace(manifest, 'routines', {_routineId}, [_routine]);
  _replaceByForeignKey(manifest, 'routine_translations', 'routine_id', {
    _routineId,
  }, _routineTranslations);
  _replaceByForeignKey(manifest, 'routine_steps', 'routine_id', {
    _routineId,
  }, _routineSteps);
  _replaceByForeignKey(manifest, 'routine_body_areas', 'routine_id', {
    _routineId,
  }, _routineBodyAreas);
  _replaceByForeignKey(manifest, 'routine_goals', 'routine_id', {
    _routineId,
  }, _routineGoals);
  _replaceByForeignKey(manifest, 'routine_positions', 'routine_id', {
    _routineId,
  }, _routinePositions);
  _replaceByForeignKey(
    manifest,
    'routine_context_memberships',
    'routine_id',
    {_routineId},
    [_assignment('routine_id', _routineId, 'context_id', _contextId)],
  );
  _replaceByForeignKey(
    manifest,
    'routine_equipment',
    'routine_id',
    {_routineId},
    [_assignment('routine_id', _routineId, 'equipment_id', _equipmentId)],
  );

  envelope['manifest_checksum'] = canonicalManifestChecksum(
    CanonicalJson.encodeBytes(manifest),
  );
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(envelope)}\n',
  );
}

Set<String> get _exerciseIds => {
  for (final exercise in _exercises) exercise.id,
};

void _replace(
  Map<String, dynamic> manifest,
  String key,
  Set<String> ids,
  List<Map<String, dynamic>> additions,
) {
  final rows = (manifest[key] as List).cast<Map<String, dynamic>>();
  manifest[key] = [
    ...rows.where((row) => !ids.contains(row['id'])),
    ...additions,
  ];
}

void _replaceByForeignKey(
  Map<String, dynamic> manifest,
  String key,
  String foreignKey,
  Set<String> ids,
  List<Map<String, dynamic>> additions,
) {
  final rows = (manifest[key] as List).cast<Map<String, dynamic>>();
  manifest[key] = [
    ...rows.where((row) => !ids.contains(row[foreignKey])),
    ...additions,
  ];
}

Map<String, dynamic> _assignment(
  String leftKey,
  String left,
  String rightKey,
  String right,
) => {leftKey: left, rightKey: right};

Map<String, dynamic> get _routine => {
  'id': _routineId,
  'public_id': 'raha_rt_000002',
  'status': 'published',
  'access_tier': 'free',
  'difficulty': 'beginner',
  'safety_approved': true,
  'estimated_duration_seconds': 300,
  'version': 1,
  'updated_at': _publishedAt,
};

List<Map<String, dynamic>> get _routineTranslations => [
  {
    'routine_id': _routineId,
    'locale': 'en',
    'name': 'Five-minute full-body reset',
    'summary': 'A calm standing-to-floor mobility flow for the whole body.',
  },
  {
    'routine_id': _routineId,
    'locale': 'ar',
    'name': 'استراحة لخمس دقائق لكامل الجسم',
    'summary': 'تسلسل حركي هادئ لكامل الجسم يبدأ بالوقوف وينتهي على الأرض.',
  },
];

List<Map<String, dynamic>> get _routineSteps => [
  for (var index = 0; index < _exercises.length; index++)
    {
      'id':
          '04000000-0000-0000-0000-${(101 + index).toString().padLeft(12, '0')}',
      'routine_id': _routineId,
      'exercise_id': _exercises[index].id,
      'position': index + 1,
      'duration_seconds': 30,
      'rest_after_seconds': 0,
      'is_optional': false,
    },
];

List<Map<String, dynamic>> get _routineBodyAreas => [
  for (final entry in _bodyAreas.entries)
    {
      'routine_id': _routineId,
      'body_area_id': entry.value,
      'relevance_weight': entry.key == 'full_body' ? 1.0 : 0.8,
    },
];

List<Map<String, dynamic>> get _routineGoals => [
  for (final id in [_easeStiffnessId, _moveFreelyId, _relaxId])
    {'routine_id': _routineId, 'goal_id': id, 'relevance_weight': 1.0},
];

List<Map<String, dynamic>> get _routinePositions => [
  for (final id in _positions.values)
    _assignment('routine_id', _routineId, 'position_id', id),
];

final class _ExerciseFixture {
  const _ExerciseFixture({
    required this.number,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.cueEn,
    required this.cueAr,
    required this.areas,
    required this.position,
    required this.durationMs,
    required this.checksum,
  });

  final int number;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String cueEn;
  final String cueAr;
  final List<String> areas;
  final String position;
  final int durationMs;
  final String checksum;

  String get suffix => number.toString().padLeft(6, '0');
  String get id =>
      '01000000-0000-0000-0000-${number.toString().padLeft(12, '0')}';
  String get publicId => 'raha_ex_$suffix';
  String get mediaId =>
      '02000000-0000-0000-0000-${number.toString().padLeft(12, '0')}';
  String get deliveryFile => '${publicId}_free50_fixture_v1_1080.mp4';

  Map<String, dynamic> get exercise => {
    'id': id,
    'public_id': publicId,
    'status': 'published',
    'access_tier': 'free',
    'difficulty': 'beginner',
    'safety_approved': true,
    'updated_at': _publishedAt,
  };

  List<Map<String, dynamic>> get translations => [
    {
      'exercise_id': id,
      'locale': 'en',
      'name': nameEn,
      'description': descriptionEn,
      'short_cue': cueEn,
    },
    {
      'exercise_id': id,
      'locale': 'ar',
      'name': nameAr,
      'description': descriptionAr,
      'short_cue': cueAr,
    },
  ];

  Map<String, dynamic> get media => {
    'id': mediaId,
    'exercise_id': id,
    'delivery_reference':
        'asset:assets/starter_content/media/videos/free50/$deliveryFile',
    'status': 'published',
    'media_type': 'video',
    'mime_type': 'video/mp4',
    'width': 1080,
    'height': 1080,
    'duration_ms': durationMs,
    'checksum_sha256': checksum,
    'is_preferred': true,
    'updated_at': _publishedAt,
  };

  List<Map<String, dynamic>> get bodyAreaAssignments => [
    for (final area in areas)
      {
        'exercise_id': id,
        'body_area_id': _bodyAreas[area],
        'relevance_weight': 1.0,
      },
  ];

  Map<String, dynamic> get positionAssignment =>
      _assignment('exercise_id', id, 'position_id', _positions[position]!);
  Map<String, dynamic> get equipmentAssignment =>
      _assignment('exercise_id', id, 'equipment_id', _equipmentId);
  List<Map<String, dynamic>> get goalAssignments => [
    for (final goalId in [_easeStiffnessId, _moveFreelyId, _relaxId])
      _assignment('exercise_id', id, 'goal_id', goalId),
  ];
}
