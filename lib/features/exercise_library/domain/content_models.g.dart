// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  status: $enumDecode(_$ContentStatusEnumMap, json['status']),
  accessTier: $enumDecode(_$AccessTierEnumMap, json['accessTier']),
  difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
  safetyReviewStatus: $enumDecode(
    _$SafetyReviewStatusEnumMap,
    json['safetyReviewStatus'],
  ),
  translations: (json['translations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      LocalizedExerciseContent.fromJson(e as Map<String, dynamic>),
    ),
  ),
  classification: ExerciseClassification.fromJson(
    json['classification'] as Map<String, dynamic>,
  ),
  providerMappings:
      (json['providerMappings'] as List<dynamic>?)
          ?.map(
            (e) => ProviderExerciseMapping.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ProviderExerciseMapping>[],
  mediaAssets:
      (json['mediaAssets'] as List<dynamic>?)
          ?.map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MediaAsset>[],
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$ContentStatusEnumMap[instance.status]!,
  'accessTier': _$AccessTierEnumMap[instance.accessTier]!,
  'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
  'safetyReviewStatus':
      _$SafetyReviewStatusEnumMap[instance.safetyReviewStatus]!,
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
  'classification': instance.classification.toJson(),
  'providerMappings': instance.providerMappings.map((e) => e.toJson()).toList(),
  'mediaAssets': instance.mediaAssets.map((e) => e.toJson()).toList(),
};

const _$ContentStatusEnumMap = {
  ContentStatus.draft: 'draft',
  ContentStatus.review: 'review',
  ContentStatus.published: 'published',
  ContentStatus.retired: 'retired',
};

const _$AccessTierEnumMap = {
  AccessTier.free: 'free',
  AccessTier.premium: 'premium',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
};

const _$SafetyReviewStatusEnumMap = {
  SafetyReviewStatus.pending: 'pending',
  SafetyReviewStatus.approved: 'approved',
  SafetyReviewStatus.rejected: 'rejected',
};

_LocalizedExerciseContent _$LocalizedExerciseContentFromJson(
  Map<String, dynamic> json,
) => _LocalizedExerciseContent(
  name: json['name'] as String,
  description: json['description'] as String?,
  shortCue: json['shortCue'] as String?,
);

Map<String, dynamic> _$LocalizedExerciseContentToJson(
  _LocalizedExerciseContent instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'shortCue': instance.shortCue,
};

_ExerciseClassification _$ExerciseClassificationFromJson(
  Map<String, dynamic> json,
) => _ExerciseClassification(
  category: json['category'] as String,
  bodyAreas: (json['bodyAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toSet(),
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const <String>{},
  positions: (json['positions'] as List<dynamic>)
      .map((e) => e as String)
      .toSet(),
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toSet(),
  contexts: (json['contexts'] as List<dynamic>).map((e) => e as String).toSet(),
);

Map<String, dynamic> _$ExerciseClassificationToJson(
  _ExerciseClassification instance,
) => <String, dynamic>{
  'category': instance.category,
  'bodyAreas': instance.bodyAreas.toList(),
  'equipment': instance.equipment.toList(),
  'positions': instance.positions.toList(),
  'goals': instance.goals.toList(),
  'contexts': instance.contexts.toList(),
};

_ProviderExerciseMapping _$ProviderExerciseMappingFromJson(
  Map<String, dynamic> json,
) => _ProviderExerciseMapping(
  providerKey: json['providerKey'] as String,
  sourceExerciseId: json['sourceExerciseId'] as String,
);

Map<String, dynamic> _$ProviderExerciseMappingToJson(
  _ProviderExerciseMapping instance,
) => <String, dynamic>{
  'providerKey': instance.providerKey,
  'sourceExerciseId': instance.sourceExerciseId,
};

_MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => _MediaAsset(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  mimeType: json['mimeType'] as String,
  deliveryFileName: json['deliveryFileName'] as String,
  checksumSha256: json['checksumSha256'] as String,
  status: $enumDecode(_$ContentStatusEnumMap, json['status']),
  isPreferred: json['isPreferred'] as bool? ?? false,
  providerKey: json['providerKey'] as String?,
  sourceExerciseId: json['sourceExerciseId'] as String?,
  sourceFileName: json['sourceFileName'] as String?,
  variant: json['variant'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$MediaAssetToJson(_MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'type': _$MediaTypeEnumMap[instance.type]!,
      'mimeType': instance.mimeType,
      'deliveryFileName': instance.deliveryFileName,
      'checksumSha256': instance.checksumSha256,
      'status': _$ContentStatusEnumMap[instance.status]!,
      'isPreferred': instance.isPreferred,
      'providerKey': instance.providerKey,
      'sourceExerciseId': instance.sourceExerciseId,
      'sourceFileName': instance.sourceFileName,
      'variant': instance.variant,
      'width': instance.width,
      'height': instance.height,
      'durationMs': instance.durationMs,
    };

const _$MediaTypeEnumMap = {
  MediaType.video: 'video',
  MediaType.image: 'image',
  MediaType.animation: 'animation',
  MediaType.audio: 'audio',
};

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  status: $enumDecode(_$ContentStatusEnumMap, json['status']),
  accessTier: $enumDecode(_$AccessTierEnumMap, json['accessTier']),
  difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
  estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num).toInt(),
  version: (json['version'] as num).toInt(),
  translations: (json['translations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      LocalizedRoutineContent.fromJson(e as Map<String, dynamic>),
    ),
  ),
  classification: RoutineClassification.fromJson(
    json['classification'] as Map<String, dynamic>,
  ),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$ContentStatusEnumMap[instance.status]!,
  'accessTier': _$AccessTierEnumMap[instance.accessTier]!,
  'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
  'estimatedDurationSeconds': instance.estimatedDurationSeconds,
  'version': instance.version,
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
  'classification': instance.classification.toJson(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
};

_LocalizedRoutineContent _$LocalizedRoutineContentFromJson(
  Map<String, dynamic> json,
) => _LocalizedRoutineContent(
  name: json['name'] as String,
  summary: json['summary'] as String,
);

Map<String, dynamic> _$LocalizedRoutineContentToJson(
  _LocalizedRoutineContent instance,
) => <String, dynamic>{'name': instance.name, 'summary': instance.summary};

_RoutineClassification _$RoutineClassificationFromJson(
  Map<String, dynamic> json,
) => _RoutineClassification(
  bodyAreas: (json['bodyAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toSet(),
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toSet(),
  positions: (json['positions'] as List<dynamic>)
      .map((e) => e as String)
      .toSet(),
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const <String>{},
  contexts:
      (json['contexts'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const <String>{},
);

Map<String, dynamic> _$RoutineClassificationToJson(
  _RoutineClassification instance,
) => <String, dynamic>{
  'bodyAreas': instance.bodyAreas.toList(),
  'goals': instance.goals.toList(),
  'positions': instance.positions.toList(),
  'equipment': instance.equipment.toList(),
  'contexts': instance.contexts.toList(),
};

_RoutineStep _$RoutineStepFromJson(Map<String, dynamic> json) => _RoutineStep(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  position: (json['position'] as num).toInt(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  repetitionCount: (json['repetitionCount'] as num?)?.toInt(),
  restAfterSeconds: (json['restAfterSeconds'] as num?)?.toInt() ?? 0,
  isOptional: json['isOptional'] as bool? ?? false,
  sideMode: json['sideMode'] as String?,
);

Map<String, dynamic> _$RoutineStepToJson(_RoutineStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'position': instance.position,
      'durationSeconds': instance.durationSeconds,
      'repetitionCount': instance.repetitionCount,
      'restAfterSeconds': instance.restAfterSeconds,
      'isOptional': instance.isOptional,
      'sideMode': instance.sideMode,
    };
