import 'dart:convert';
import 'dart:typed_data';

/// The single manifest contract version implemented by this client.
const contentReleaseContractVersion = 'raha-content-release-v1';

/// Allowed taxonomy kinds after the server's six dedicated taxonomy tables are
/// normalized into the local unified taxonomy store.
const contentTaxonomyKinds = <String>{
  'body_area',
  'goal',
  'position',
  'equipment',
  'context',
  'tag',
};

/// A release that fails validation or application. [code] is a stable,
/// language-neutral diagnostic; the message never embeds private payloads.
final class ContentReleaseException implements Exception {
  const ContentReleaseException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ContentReleaseException($code): $message';
}

/// The server `release` object inside a manifest.
final class ManifestRelease {
  const ManifestRelease({
    required this.id,
    required this.version,
    required this.minimumAppVersion,
    required this.publishedAt,
  });

  final String id;
  final String version;
  final String? minimumAppVersion;
  final DateTime? publishedAt;
}

final class ManifestExercise {
  const ManifestExercise({
    required this.id,
    required this.publicId,
    required this.status,
    required this.accessTier,
    required this.difficulty,
    required this.safetyApproved,
    required this.updatedAt,
  });

  final String id;
  final String publicId;
  final String status;
  final String accessTier;
  final String difficulty;

  /// Literal `safety_approved` flag from the manifest. The repository requires
  /// this to be exactly `true`; it is never assumed.
  final bool safetyApproved;
  final DateTime? updatedAt;
}

final class ManifestExerciseTranslation {
  const ManifestExerciseTranslation({
    required this.exerciseId,
    required this.locale,
    required this.name,
    required this.description,
    required this.shortCue,
  });

  final String exerciseId;
  final String locale;
  final String name;
  final String? description;
  final String? shortCue;
}

final class ManifestMediaAsset {
  const ManifestMediaAsset({
    required this.id,
    required this.exerciseId,
    required this.deliveryReference,
    required this.status,
    required this.mediaType,
    required this.mimeType,
    required this.checksumSha256,
    required this.isPreferred,
    required this.updatedAt,
    required this.width,
    required this.height,
    required this.durationMs,
  });

  final String id;
  final String exerciseId;
  final String deliveryReference;

  /// `published` (delivered, checksum present) or `pending` (delivery reference
  /// reserved, approved asset not yet provided). A `pending` asset has no
  /// checksum.
  final String status;
  final String mediaType;
  final String mimeType;
  final String? checksumSha256;
  final bool isPreferred;
  final DateTime? updatedAt;
  final int? width;
  final int? height;
  final int? durationMs;
}

final class ManifestRoutine {
  const ManifestRoutine({
    required this.id,
    required this.publicId,
    required this.status,
    required this.accessTier,
    required this.difficulty,
    required this.safetyApproved,
    required this.estimatedDurationSeconds,
    required this.version,
    required this.updatedAt,
  });

  final String id;
  final String publicId;
  final String status;
  final String accessTier;
  final String difficulty;

  /// Literal `safety_approved` flag from the manifest; never assumed.
  final bool safetyApproved;
  final int estimatedDurationSeconds;
  final int version;
  final DateTime? updatedAt;
}

final class ManifestRoutineTranslation {
  const ManifestRoutineTranslation({
    required this.routineId,
    required this.locale,
    required this.name,
    required this.summary,
  });

  final String routineId;
  final String locale;
  final String name;
  final String summary;
}

final class ManifestRoutineStep {
  const ManifestRoutineStep({
    required this.id,
    required this.routineId,
    required this.exerciseId,
    required this.position,
    required this.durationSeconds,
    required this.repetitionCount,
    required this.restAfterSeconds,
    required this.isOptional,
    required this.sideMode,
  });

  final String id;
  final String routineId;
  final String exerciseId;
  final int position;
  final int? durationSeconds;
  final int? repetitionCount;
  final int restAfterSeconds;
  final bool isOptional;
  final String? sideMode;
}

/// A normalized taxonomy entry plus its localized labels.
final class ManifestTaxonomy {
  const ManifestTaxonomy({
    required this.id,
    required this.kind,
    required this.key,
    required this.sortOrder,
    required this.active,
    required this.labels,
  });

  final String id;
  final String kind;
  final String key;
  final int sortOrder;
  final bool active;
  final Map<String, String> labels;
}

/// One exercise→taxonomy or routine→taxonomy membership row. [entityId] is the
/// exercise/routine UUID, [taxonomyId] is the taxonomy UUID.
final class ManifestTaxonomyAssignment {
  const ManifestTaxonomyAssignment({
    required this.entityId,
    required this.taxonomyId,
    required this.relevanceWeight,
  });

  final String entityId;
  final String taxonomyId;
  final double relevanceWeight;
}

final class ManifestTombstone {
  const ManifestTombstone({
    required this.entityType,
    required this.entityPublicId,
    required this.entityId,
    required this.retiredAt,
  });

  final String entityType;

  /// Stable Raha public id of the retired exercise/routine. Media tombstones
  /// use [entityId] (their local id is the media UUID) and leave this null.
  final String? entityPublicId;

  /// Server UUID of the retired entity (provenance; the authority for media).
  final String? entityId;
  final DateTime? retiredAt;
}

/// Typed, provider-neutral view of a complete, compatible catalog snapshot.
///
/// [ContentReleaseManifest.fromJson] accepts the canonical server manifest
/// shape (snake_case keys) returned by `get_next_content_release`. It normalizes
/// the six server taxonomy tables and their join tables into the unified local
/// taxonomy representation while preserving the UUID→Raha/public-key and
/// UUID→taxonomy-key maps needed to resolve relationships.
final class ContentReleaseManifest {
  ContentReleaseManifest({
    required this.contractVersion,
    required this.release,
    required this.exercises,
    required this.exerciseTranslations,
    required this.mediaAssets,
    required this.routines,
    required this.routineTranslations,
    required this.routineSteps,
    required this.taxonomies,
    required this.exerciseTaxonomies,
    required this.routineTaxonomies,
    required this.tombstones,
  });

  factory ContentReleaseManifest.fromJson(Map<String, dynamic> json) {
    final exercises = _objects(json['exercises'])
        .map(_exerciseFromJson)
        .toList();
    final routines = _objects(json['routines']).map(_routineFromJson).toList();

    return ContentReleaseManifest(
      contractVersion: _string(json['contract_version'], required: true)!,
      release: _releaseFromJson(_object(json['release'])),
      exercises: exercises,
      exerciseTranslations: _objects(json['exercise_translations'])
          .map(_exerciseTranslationFromJson)
          .toList(),
      mediaAssets: _objects(json['media_assets'])
          .map(_mediaAssetFromJson)
          .toList(),
      routines: routines,
      routineTranslations: _objects(json['routine_translations'])
          .map(_routineTranslationFromJson)
          .toList(),
      routineSteps: _objects(json['routine_steps'])
          .map(_routineStepFromJson)
          .toList(),
      taxonomies: _parseTaxonomies(json),
      exerciseTaxonomies: _parseAssignments(json, exercise: true),
      routineTaxonomies: _parseAssignments(json, exercise: false),
      tombstones: _objects(json['tombstones']).map(_tombstoneFromJson).toList(),
    );
  }

  final String contractVersion;
  final ManifestRelease release;
  final List<ManifestExercise> exercises;
  final List<ManifestExerciseTranslation> exerciseTranslations;
  final List<ManifestMediaAsset> mediaAssets;
  final List<ManifestRoutine> routines;
  final List<ManifestRoutineTranslation> routineTranslations;
  final List<ManifestRoutineStep> routineSteps;
  final List<ManifestTaxonomy> taxonomies;
  final List<ManifestTaxonomyAssignment> exerciseTaxonomies;
  final List<ManifestTaxonomyAssignment> routineTaxonomies;
  final List<ManifestTombstone> tombstones;

  /// Server exercise UUID → Raha public id.
  late final Map<String, String> exercisePublicIdByUuid = {
    for (final exercise in exercises) exercise.id: exercise.publicId,
  };

  /// Server routine UUID → Raha public id.
  late final Map<String, String> routinePublicIdByUuid = {
    for (final routine in routines) routine.id: routine.publicId,
  };

  /// Server taxonomy UUID → taxonomy key.
  late final Map<String, String> taxonomyKeyByUuid = {
    for (final taxonomy in taxonomies) taxonomy.id: taxonomy.key,
  };

  static List<ManifestTaxonomy> _parseTaxonomies(Map<String, dynamic> json) {
    final result = <ManifestTaxonomy>[];
    void addSection({
      required String definitions,
      required String translations,
      required String idField,
      required String kind,
    }) {
      final labels = <String, Map<String, String>>{};
      for (final row in _objects(json[translations])) {
        final id = _string(row[idField], required: true)!;
        final locale = _string(row['locale'], required: true)!;
        final name = _string(row['name'], required: true)!;
        labels.putIfAbsent(id, () => {})[locale] = name;
      }
      for (final row in _objects(json[definitions])) {
        final id = _string(row['id'], required: true)!;
        result.add(
          ManifestTaxonomy(
            id: id,
            kind: kind,
            key: _string(row['key'], required: true)!,
            sortOrder: _int(row['sort_order']) ?? 0,
            active: row['active'] == true,
            labels: Map.unmodifiable(labels[id] ?? const {}),
          ),
        );
      }
    }

    addSection(
      definitions: 'body_areas',
      translations: 'body_area_translations',
      idField: 'body_area_id',
      kind: 'body_area',
    );
    addSection(
      definitions: 'goals',
      translations: 'goal_translations',
      idField: 'goal_id',
      kind: 'goal',
    );
    addSection(
      definitions: 'movement_positions',
      translations: 'movement_position_translations',
      idField: 'position_id',
      kind: 'position',
    );
    addSection(
      definitions: 'equipment',
      translations: 'equipment_translations',
      idField: 'equipment_id',
      kind: 'equipment',
    );
    addSection(
      definitions: 'routine_contexts',
      translations: 'routine_context_translations',
      idField: 'context_id',
      kind: 'context',
    );
    addSection(
      definitions: 'tags',
      translations: 'tag_translations',
      idField: 'tag_id',
      kind: 'tag',
    );
    return result;
  }

  static List<ManifestTaxonomyAssignment> _parseAssignments(
    Map<String, dynamic> json, {
    required bool exercise,
  }) {
    final result = <ManifestTaxonomyAssignment>[];
    final entityField = exercise ? 'exercise_id' : 'routine_id';

    void addSection(
      String section,
      String taxonomyField, {
      bool weighted = false,
    }) {
      for (final row in _objects(json[section])) {
        final entityId = _string(row[entityField], required: true)!;
        final taxonomyId = _string(row[taxonomyField], required: true)!;
        result.add(
          ManifestTaxonomyAssignment(
            entityId: entityId,
            taxonomyId: taxonomyId,
            relevanceWeight: weighted
                ? _double(row['relevance_weight']) ?? 1.0
                : 1.0,
          ),
        );
      }
    }

    if (exercise) {
      addSection('exercise_body_areas', 'body_area_id', weighted: true);
      addSection('exercise_positions', 'position_id');
      addSection('exercise_equipment', 'equipment_id');
      addSection('exercise_goals', 'goal_id');
      addSection('exercise_tags', 'tag_id');
    } else {
      addSection('routine_body_areas', 'body_area_id', weighted: true);
      addSection('routine_goals', 'goal_id', weighted: true);
      addSection('routine_positions', 'position_id');
      addSection('routine_context_memberships', 'context_id');
      addSection('routine_equipment', 'equipment_id');
    }
    return result;
  }
}

/// Typed release payload returned by a [ContentReleaseSource].
///
/// [canonicalManifestBytes] are the exact canonical UTF-8 JSON bytes over which
/// [manifestChecksum] (lower-case hex SHA-256) is computed. A repository MUST
/// verify `sha256(canonicalManifestBytes) == manifestChecksum` before applying.
final class ContentReleaseEnvelope {
  const ContentReleaseEnvelope({
    required this.releaseId,
    required this.version,
    required this.manifestChecksum,
    required this.canonicalManifestBytes,
    required this.manifest,
    this.minimumAppVersion,
    this.publishedAt,
  });

  final String releaseId;
  final String version;
  final String? minimumAppVersion;
  final DateTime? publishedAt;
  final String manifestChecksum;
  final Uint8List canonicalManifestBytes;
  final ContentReleaseManifest manifest;
}

ManifestExercise _exerciseFromJson(Map<String, dynamic> json) =>
    ManifestExercise(
      id: _string(json['id'], required: true)!,
      publicId: _string(json['public_id'], required: true)!,
      status: _string(json['status'], required: true)!,
      accessTier: _string(json['access_tier'], required: true)!,
      difficulty: _string(json['difficulty'], required: true)!,
      safetyApproved: json['safety_approved'] == true,
      updatedAt: _dateTime(json['updated_at']),
    );

ManifestExerciseTranslation _exerciseTranslationFromJson(
  Map<String, dynamic> json,
) => ManifestExerciseTranslation(
  exerciseId: _string(json['exercise_id'], required: true)!,
  locale: _string(json['locale'], required: true)!,
  name: _string(json['name'], required: true)!,
  description: _string(json['description']),
  shortCue: _string(json['short_cue']),
);

ManifestMediaAsset _mediaAssetFromJson(Map<String, dynamic> json) =>
    ManifestMediaAsset(
      id: _string(json['id'], required: true)!,
      exerciseId: _string(json['exercise_id'], required: true)!,
      deliveryReference: _string(json['delivery_reference'], required: true)!,
      status: _string(json['status'], required: true)!,
      mediaType: _string(json['media_type'], required: true)!,
      mimeType: _string(json['mime_type'], required: true)!,
      checksumSha256: _string(json['checksum_sha256']),
      isPreferred: json['is_preferred'] == true,
      updatedAt: _dateTime(json['updated_at']),
      width: _int(json['width']),
      height: _int(json['height']),
      durationMs: _int(json['duration_ms']),
    );

ManifestRoutine _routineFromJson(Map<String, dynamic> json) => ManifestRoutine(
  id: _string(json['id'], required: true)!,
  publicId: _string(json['public_id'], required: true)!,
  status: _string(json['status'], required: true)!,
  accessTier: _string(json['access_tier'], required: true)!,
  difficulty: _string(json['difficulty'], required: true)!,
  safetyApproved: json['safety_approved'] == true,
  estimatedDurationSeconds: _int(
    json['estimated_duration_seconds'],
    required: true,
  )!,
  version: _int(json['version'], required: true)!,
  updatedAt: _dateTime(json['updated_at']),
);

ManifestRoutineTranslation _routineTranslationFromJson(
  Map<String, dynamic> json,
) => ManifestRoutineTranslation(
  routineId: _string(json['routine_id'], required: true)!,
  locale: _string(json['locale'], required: true)!,
  name: _string(json['name'], required: true)!,
  summary: _string(json['summary'], required: true)!,
);

ManifestRoutineStep _routineStepFromJson(Map<String, dynamic> json) =>
    ManifestRoutineStep(
      id: _string(json['id'], required: true)!,
      routineId: _string(json['routine_id'], required: true)!,
      exerciseId: _string(json['exercise_id'], required: true)!,
      position: _int(json['position'], required: true)!,
      durationSeconds: _int(json['duration_seconds']),
      repetitionCount: _int(json['repetition_count']),
      restAfterSeconds: _int(json['rest_after_seconds']) ?? 0,
      isOptional: json['is_optional'] == true,
      sideMode: _string(json['side_mode']),
    );

ManifestTombstone _tombstoneFromJson(Map<String, dynamic> json) =>
    ManifestTombstone(
      entityType: _string(json['entity_type'], required: true)!,
      entityPublicId: _string(json['entity_public_id']),
      entityId: _string(json['entity_id']),
      retiredAt: _dateTime(json['retired_at']),
    );

ManifestRelease _releaseFromJson(Map<String, dynamic> json) => ManifestRelease(
  id: _string(json['id'], required: true)!,
  version: _string(json['version'], required: true)!,
  minimumAppVersion: _string(json['minimum_app_version']),
  publishedAt: _dateTime(json['published_at']),
);

List<Map<String, dynamic>> _objects(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList();
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map) {
    throw const ContentReleaseException(
      'invalid_release',
      'Release metadata is missing',
    );
  }
  return Map<String, dynamic>.from(value);
}

String? _string(Object? value, {bool required = false}) {
  if (value is String) return value;
  if (required) {
    throw const ContentReleaseException(
      'invalid_release',
      'Required string field is missing',
    );
  }
  return null;
}

int? _int(Object? value, {bool required = false}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (required) {
    throw const ContentReleaseException(
      'invalid_release',
      'Required integer field is missing',
    );
  }
  return null;
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return null;
}

DateTime? _dateTime(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

/// Decodes a manifest JSON string into a typed manifest. Throws
/// [ContentReleaseException] when the document is not a JSON object.
ContentReleaseManifest decodeManifestString(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const ContentReleaseException(
      'invalid_release',
      'Manifest is not JSON',
    );
  }
  if (decoded is! Map) {
    throw const ContentReleaseException(
      'invalid_release',
      'Manifest is not an object',
    );
  }
  return ContentReleaseManifest.fromJson(Map<String, dynamic>.from(decoded));
}
