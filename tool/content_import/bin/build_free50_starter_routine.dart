import 'dart:convert';
import 'dart:io';

import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';

const _manifestPath = 'assets/starter_content/manifests/starter_catalog.json';
const _guidancePath = 'content/authoring/exercise_guidance.json';
const _routineGuidancePath = 'content/authoring/routine_guidance.json';
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
    areas: ['shoulders', 'upper_back'],
    position: 'standing',
    durationMs: 1811,
    checksum:
        '0e146ee8d59fbd30dbf335f2f21172d6e39906576139167d6ba1ede0180908c9',
  ),
  const _ExerciseFixture(
    number: 102,
    areas: ['shoulders'],
    position: 'standing',
    durationMs: 5480,
    checksum:
        'cc6a9c8d00264497cb69bc5ba80f904e47a9ccd5aab23baae6a4cf9a878a510f',
  ),
  const _ExerciseFixture(
    number: 103,
    areas: ['upper_back', 'shoulders'],
    position: 'standing',
    durationMs: 4667,
    checksum:
        'c10a58cb151f5a5ff78e0ccbd30395ecfbbf6cd6aa66822b6b665284ea3c84f1',
  ),
  const _ExerciseFixture(
    number: 104,
    areas: ['upper_back', 'full_body'],
    position: 'standing',
    durationMs: 4342,
    checksum:
        'c210d9eca171243063705b5a8e3e28cdcfe034069a4b1ca760ac22bcd358fdfe',
  ),
  const _ExerciseFixture(
    number: 105,
    areas: ['hips'],
    position: 'standing',
    durationMs: 11772,
    checksum:
        '59339ad55ac4e037e4f1987b86c1ee84e8f237a3397fb62c5161a555b953f9b6',
  ),
  const _ExerciseFixture(
    number: 106,
    areas: ['hips', 'lower_back'],
    position: 'standing',
    durationMs: 9079,
    checksum:
        '2012b9ffe5c5c63beae65025686889bc962d38a6e8b33d15c3864df3dbe462d3',
  ),
  const _ExerciseFixture(
    number: 107,
    areas: ['lower_back', 'hips'],
    position: 'standing',
    durationMs: 11076,
    checksum:
        'ff3cddd7db8c512294e8d0e96ce5e053dce4a52a14d706fa7de5ff24cca0f0a7',
  ),
  const _ExerciseFixture(
    number: 108,
    areas: ['hips'],
    position: 'floor',
    durationMs: 3274,
    checksum:
        '4984907e62eaeca167c41585fa583fdd720fbaece057883c6261f7069a17730e',
  ),
  const _ExerciseFixture(
    number: 109,
    areas: ['upper_back', 'lower_back'],
    position: 'seated',
    durationMs: 2809,
    checksum:
        '33e06e288881e7d74663bfbd269523077b25e89426a1ed759173100d999be7a0',
  ),
  const _ExerciseFixture(
    number: 110,
    areas: ['hips', 'lower_back'],
    position: 'floor',
    durationMs: 4342,
    checksum:
        'f8530ebad427d89fd8b2f368522a67c83a4749add1aa1fa319adc7a0f880464f',
  ),
];

void main(List<String> arguments) {
  final manifestPath = _pathArgument(arguments, '--manifest=', _manifestPath);
  final guidancePath = _pathArgument(arguments, '--guidance=', _guidancePath);
  final routineGuidancePath = _pathArgument(
    arguments,
    '--routine-guidance=',
    _routineGuidancePath,
  );
  final guidance = _loadGuidance(guidancePath);
  final routineGuidance = _loadRoutineGuidance(routineGuidancePath);
  final file = File(manifestPath);
  final envelope = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final manifest = envelope['manifest'] as Map<String, dynamic>;

  _replace(manifest, 'exercises', _exerciseIds, [
    for (final exercise in _exercises) exercise.exercise,
  ]);
  final exerciseIdsByPublicId = {
    for (final exercise
        in (manifest['exercises'] as List).cast<Map<String, dynamic>>())
      exercise['public_id'] as String: exercise['id'] as String,
  };
  if (guidance.keys
          .toSet()
          .difference(exerciseIdsByPublicId.keys.toSet())
          .isNotEmpty ||
      exerciseIdsByPublicId.keys
          .toSet()
          .difference(guidance.keys.toSet())
          .isNotEmpty) {
    throw FormatException(
      'Guidance must cover every exercise in the starter catalog.',
    );
  }
  manifest['exercise_translations'] = [
    for (final exercise in exerciseIdsByPublicId.entries)
      for (final locale in const ['en', 'ar'])
        guidance[exercise.key]![locale]!.toManifestRow(exercise.value, locale),
  ];
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
  final routines = (manifest['routines'] as List).cast<Map<String, dynamic>>();
  final routineIdsByPublicId = {
    for (final routine in routines)
      routine['public_id'] as String: routine['id'] as String,
  };
  if (routineGuidance.keys
          .toSet()
          .difference(routineIdsByPublicId.keys.toSet())
          .isNotEmpty ||
      routineIdsByPublicId.keys
          .toSet()
          .difference(routineGuidance.keys.toSet())
          .isNotEmpty) {
    throw const FormatException(
      'Routine guidance must cover every routine in the starter catalog.',
    );
  }
  final stepIds = <String>{};
  for (final routine in routineGuidance.values) {
    for (final step in routine.steps) {
      if (!stepIds.add(step.stepId)) {
        throw FormatException('Duplicate routine step ID: ${step.stepId}.');
      }
    }
  }
  manifest['routine_translations'] = [
    for (final routine in routineIdsByPublicId.entries)
      for (final locale in const ['en', 'ar'])
        routineGuidance[routine.key]!.translations[locale]!.toManifestRow(
          routine.value,
          locale,
        ),
  ];
  manifest['routine_steps'] = [
    for (final routine in routineIdsByPublicId.entries)
      for (
        var index = 0;
        index < routineGuidance[routine.key]!.steps.length;
        index++
      )
        routineGuidance[routine.key]!.steps[index].toManifestRow(
          routineId: routine.value,
          exerciseId:
              exerciseIdsByPublicId[routineGuidance[routine.key]!
                  .steps[index]
                  .exerciseId] ??
              (throw FormatException(
                'Unknown exercise in ${routine.key}: '
                '${routineGuidance[routine.key]!.steps[index].exerciseId}.',
              )),
          position: index + 1,
        ),
  ];
  for (final routine in routines) {
    final steps = routineGuidance[routine['public_id']]!.steps;
    routine['estimated_duration_seconds'] = steps.fold<int>(
      0,
      (sum, step) => sum + step.durationSeconds + step.restAfterSeconds,
    );
  }
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

  final previousChecksum = envelope['manifest_checksum'] as String;
  var checksum = canonicalManifestChecksum(CanonicalJson.encodeBytes(manifest));
  if (checksum != previousChecksum) {
    // Bootstrap only applies a bundled release newer than the local one.
    final release = manifest['release'] as Map<String, dynamic>;
    final nextId = int.parse(release['id'] as String) + 1;
    release['id'] = '$nextId';
    release['version'] = 'starter-${nextId + 1}';
    release['published_at'] = DateTime.now().toUtc().toIso8601String();
    checksum = canonicalManifestChecksum(CanonicalJson.encodeBytes(manifest));
  }
  envelope['manifest_checksum'] = checksum;
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(envelope)}\n',
  );
}

String _pathArgument(List<String> arguments, String prefix, String fallback) {
  final matches = arguments.where((argument) => argument.startsWith(prefix));
  if (matches.length > 1 ||
      arguments.any(
        (argument) =>
            !argument.startsWith('--manifest=') &&
            !argument.startsWith('--guidance=') &&
            !argument.startsWith('--routine-guidance='),
      )) {
    throw ArgumentError(
      'Expected --manifest=PATH, --guidance=PATH, and --routine-guidance=PATH.',
    );
  }
  return matches.isEmpty ? fallback : matches.single.substring(prefix.length);
}

Map<String, _RoutineGuidance> _loadRoutineGuidance(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Routine guidance must be keyed by Raha routine ID.',
    );
  }
  return {
    for (final entry in decoded.entries)
      entry.key: _RoutineGuidance.fromJson(entry.key, entry.value),
  };
}

final class _RoutineGuidance {
  const _RoutineGuidance(this.translations, this.steps);

  final Map<String, _LocalizedRoutine> translations;
  final List<_RoutineStep> steps;

  factory _RoutineGuidance.fromJson(String publicId, Object? value) {
    if (!RegExp(r'^raha_rt_\d{6}$').hasMatch(publicId) ||
        value is! Map<String, dynamic> ||
        value.keys.toSet().difference({'en', 'ar', 'steps'}).isNotEmpty ||
        !value.containsKey('en') ||
        !value.containsKey('ar') ||
        value['steps'] is! List) {
      throw FormatException(
        'Invalid bilingual routine guidance for $publicId.',
      );
    }
    final rawSteps = value['steps'] as List;
    if (rawSteps.isEmpty || rawSteps.length > 100) {
      throw FormatException('Routine $publicId needs 1–100 steps.');
    }
    return _RoutineGuidance(
      {
        for (final locale in const ['en', 'ar'])
          locale: _LocalizedRoutine.fromJson(publicId, locale, value[locale]),
      },
      [
        for (final rawStep in rawSteps)
          _RoutineStep.fromJson(publicId, rawStep),
      ],
    );
  }
}

final class _LocalizedRoutine {
  const _LocalizedRoutine(this.name, this.summary);

  final String name;
  final String summary;

  factory _LocalizedRoutine.fromJson(
    String publicId,
    String locale,
    Object? value,
  ) {
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference({'name', 'summary'}).isNotEmpty ||
        value['name'] is! String ||
        (value['name'] as String).trim().isEmpty ||
        value['summary'] is! String ||
        (value['summary'] as String).trim().isEmpty) {
      throw FormatException('Invalid $locale routine text for $publicId.');
    }
    return _LocalizedRoutine(
      (value['name'] as String).trim(),
      (value['summary'] as String).trim(),
    );
  }

  Map<String, dynamic> toManifestRow(String routineId, String locale) => {
    'routine_id': routineId,
    'locale': locale,
    'name': name,
    'summary': summary,
  };
}

final class _RoutineStep {
  const _RoutineStep(
    this.stepId,
    this.exerciseId,
    this.durationSeconds,
    this.restAfterSeconds,
    this.isOptional,
  );

  final String stepId;
  final String exerciseId;
  final int durationSeconds;
  final int restAfterSeconds;
  final bool isOptional;

  factory _RoutineStep.fromJson(String publicId, Object? value) {
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference({
          'step_id',
          'exercise_id',
          'duration_seconds',
          'rest_after_seconds',
          'is_optional',
        }).isNotEmpty ||
        value['step_id'] is! String ||
        !RegExp(r'^raha_rs_\d{6}$').hasMatch(value['step_id'] as String) ||
        value['exercise_id'] is! String ||
        !RegExp(r'^raha_ex_\d{6}$').hasMatch(value['exercise_id'] as String) ||
        value['duration_seconds'] is! int ||
        (value['duration_seconds'] as int) <= 0 ||
        value['rest_after_seconds'] is! int ||
        (value['rest_after_seconds'] as int) < 0 ||
        value['is_optional'] is! bool) {
      throw FormatException('Invalid step in routine $publicId.');
    }
    return _RoutineStep(
      value['step_id'] as String,
      value['exercise_id'] as String,
      value['duration_seconds'] as int,
      value['rest_after_seconds'] as int,
      value['is_optional'] as bool,
    );
  }

  Map<String, dynamic> toManifestRow({
    required String routineId,
    required String exerciseId,
    required int position,
  }) => {
    'id': '04000000-0000-0000-0000-${stepId.substring(8).padLeft(12, '0')}',
    'routine_id': routineId,
    'exercise_id': exerciseId,
    'position': position,
    'duration_seconds': durationSeconds,
    'rest_after_seconds': restAfterSeconds,
    'is_optional': isOptional,
  };
}

Map<String, Map<String, _LocalizedGuidance>> _loadGuidance(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Guidance must be keyed by Raha exercise ID.');
  }
  return {
    for (final entry in decoded.entries)
      entry.key: _parseTranslations(entry.key, entry.value),
  };
}

Map<String, _LocalizedGuidance> _parseTranslations(
  String exerciseId,
  Object? value,
) {
  if (!RegExp(r'^raha_ex_\d{6}$').hasMatch(exerciseId) ||
      value is! Map<String, dynamic> ||
      value.keys.toSet().difference({'en', 'ar'}).isNotEmpty ||
      !value.containsKey('en') ||
      !value.containsKey('ar')) {
    throw FormatException('Invalid bilingual guidance for $exerciseId.');
  }
  final translations = {
    for (final locale in const ['en', 'ar'])
      locale: _LocalizedGuidance.fromJson(exerciseId, locale, value[locale]),
  };
  if (translations['en']!.instructions.length !=
      translations['ar']!.instructions.length) {
    throw FormatException('Instruction step counts differ for $exerciseId.');
  }
  return translations;
}

final class _LocalizedGuidance {
  const _LocalizedGuidance(
    this.name,
    this.description,
    this.shortCue,
    this.instructions,
  );

  final String name;
  final String description;
  final String shortCue;
  final List<String> instructions;

  factory _LocalizedGuidance.fromJson(
    String exerciseId,
    String locale,
    Object? value,
  ) {
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference({
          'name',
          'description',
          'short_cue',
          'instructions',
        }).isNotEmpty ||
        !value.containsKey('instructions')) {
      throw FormatException('Invalid $locale guidance for $exerciseId.');
    }
    String textField(String key) {
      final field = value[key];
      if (field is! String || field.trim().isEmpty) {
        throw FormatException('Invalid $locale $key for $exerciseId.');
      }
      return field.trim();
    }

    final steps = value['instructions'];
    if (steps is! List ||
        steps.any((step) => step is! String || step.trim().isEmpty)) {
      throw FormatException('Invalid $locale instructions for $exerciseId.');
    }
    return _LocalizedGuidance(
      textField('name'),
      textField('description'),
      textField('short_cue'),
      [for (final step in steps) (step as String).trim()],
    );
  }

  Map<String, dynamic> toManifestRow(String exerciseId, String locale) => {
    'exercise_id': exerciseId,
    'locale': locale,
    'name': name,
    'description': description,
    'short_cue': shortCue,
    if (instructions.isNotEmpty) 'instructions': instructions,
  };
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
    required this.areas,
    required this.position,
    required this.durationMs,
    required this.checksum,
  });

  final int number;
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
