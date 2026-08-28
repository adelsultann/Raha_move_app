import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_models.freezed.dart';
part 'content_models.g.dart';

/// Publication lifecycle controlled by Raha Move, never a footage provider.
enum ContentStatus { draft, review, published, retired }

enum AccessTier { free, premium }

enum DifficultyLevel { beginner, intermediate, advanced }

enum SafetyReviewStatus { pending, approved, rejected }

/// Media is intentionally provider-neutral. A delivery file is not a URL.
enum MediaType { video, image, animation, audio }

/// Language-neutral metadata owned by Raha Move for one movement.
@Freezed(toJson: true)
abstract class Exercise with _$Exercise {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Exercise({
    required String id,
    required ContentStatus status,
    required AccessTier accessTier,
    required DifficultyLevel difficulty,
    required SafetyReviewStatus safetyReviewStatus,
    required Map<String, LocalizedExerciseContent> translations,
    required ExerciseClassification classification,
    @Default(<ProviderExerciseMapping>[])
    List<ProviderExerciseMapping> providerMappings,
    @Default(<MediaAsset>[]) List<MediaAsset> mediaAssets,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, Object?> json) =>
      _$ExerciseFromJson(json);
}

/// Human-reviewed content owned by Raha Move. It must not be provider text.
@freezed
abstract class LocalizedExerciseContent with _$LocalizedExerciseContent {
  const factory LocalizedExerciseContent({
    required String name,
    String? description,
    String? shortCue,
  }) = _LocalizedExerciseContent;

  factory LocalizedExerciseContent.fromJson(Map<String, Object?> json) =>
      _$LocalizedExerciseContentFromJson(json);
}

/// Raha taxonomy keys used by catalog filtering and later recommendation rules.
@freezed
abstract class ExerciseClassification with _$ExerciseClassification {
  const factory ExerciseClassification({
    required String category,
    required Set<String> bodyAreas,
    @Default(<String>{}) Set<String> equipment,
    required Set<String> positions,
    required Set<String> goals,
    required Set<String> contexts,
  }) = _ExerciseClassification;

  factory ExerciseClassification.fromJson(Map<String, Object?> json) =>
      _$ExerciseClassificationFromJson(json);
}

/// Import provenance only; neither field is a Raha identity.
@freezed
abstract class ProviderExerciseMapping with _$ProviderExerciseMapping {
  const factory ProviderExerciseMapping({
    required String providerKey,
    required String sourceExerciseId,
  }) = _ProviderExerciseMapping;

  factory ProviderExerciseMapping.fromJson(Map<String, Object?> json) =>
      _$ProviderExerciseMappingFromJson(json);
}

/// A replaceable demonstration of an exercise. [deliveryFileName] is a
/// language-neutral Raha-controlled object name, never a signed URL.
@freezed
abstract class MediaAsset with _$MediaAsset {
  const factory MediaAsset({
    required String id,
    required String exerciseId,
    required MediaType type,
    required String mimeType,
    required String deliveryFileName,
    required String checksumSha256,
    required ContentStatus status,
    @Default(false) bool isPreferred,
    String? providerKey,
    String? sourceExerciseId,
    String? sourceFileName,
    String? variant,
    int? width,
    int? height,
    int? durationMs,
  }) = _MediaAsset;

  factory MediaAsset.fromJson(Map<String, Object?> json) =>
      _$MediaAssetFromJson(json);
}

/// A reusable, localized guided movement sequence.
@Freezed(toJson: true)
abstract class Routine with _$Routine {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Routine({
    required String id,
    required ContentStatus status,
    required AccessTier accessTier,
    required DifficultyLevel difficulty,
    required int estimatedDurationSeconds,
    required int version,
    required Map<String, LocalizedRoutineContent> translations,
    required RoutineClassification classification,
    required List<RoutineStep> steps,
  }) = _Routine;

  factory Routine.fromJson(Map<String, Object?> json) =>
      _$RoutineFromJson(json);
}

@freezed
abstract class LocalizedRoutineContent with _$LocalizedRoutineContent {
  const factory LocalizedRoutineContent({
    required String name,
    required String summary,
  }) = _LocalizedRoutineContent;

  factory LocalizedRoutineContent.fromJson(Map<String, Object?> json) =>
      _$LocalizedRoutineContentFromJson(json);
}

@freezed
abstract class RoutineClassification with _$RoutineClassification {
  const factory RoutineClassification({
    required Set<String> bodyAreas,
    required Set<String> goals,
    required Set<String> positions,
    @Default(<String>{}) Set<String> equipment,
    @Default(<String>{}) Set<String> contexts,
  }) = _RoutineClassification;

  factory RoutineClassification.fromJson(Map<String, Object?> json) =>
      _$RoutineClassificationFromJson(json);
}

/// How a stable exercise is scheduled in a particular routine.
@freezed
abstract class RoutineStep with _$RoutineStep {
  const factory RoutineStep({
    required String id,
    required String exerciseId,
    required int position,
    int? durationSeconds,
    int? repetitionCount,
    @Default(0) int restAfterSeconds,
    @Default(false) bool isOptional,
    String? sideMode,
  }) = _RoutineStep;

  factory RoutineStep.fromJson(Map<String, Object?> json) =>
      _$RoutineStepFromJson(json);
}
