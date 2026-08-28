import 'content_models.dart';

/// The taxonomy snapshot provided with a content release or bundled catalog.
final class ContentTaxonomy {
  const ContentTaxonomy({
    required this.categories,
    required this.bodyAreas,
    required this.equipment,
    required this.positions,
    required this.goals,
    required this.contexts,
  });

  final Set<String> categories;
  final Set<String> bodyAreas;
  final Set<String> equipment;
  final Set<String> positions;
  final Set<String> goals;
  final Set<String> contexts;
}

enum ContentValidationCode {
  invalidRahaId,
  missingRequiredLocale,
  emptyLocalizedField,
  invalidTaxonomyKey,
  duplicateProviderMapping,
  invalidMediaReference,
  invalidMediaStatus,
  invalidMediaMetadata,
  missingPreferredPlayableMedia,
  invalidRoutineDuration,
  invalidRoutineVersion,
  emptyRoutine,
  invalidStepPosition,
  duplicateStepPosition,
  invalidStepMeasure,
  invalidStepRest,
  unknownExercise,
  unpublishedExercise,
}

final class ContentValidationError {
  const ContentValidationError(this.code, this.subject);

  final ContentValidationCode code;
  final String subject;

  @override
  bool operator ==(Object other) =>
      other is ContentValidationError &&
      other.code == code &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(code, subject);
}

final class ContentValidationResult {
  const ContentValidationResult(this.errors);

  final List<ContentValidationError> errors;

  bool get isValid => errors.isEmpty;
}

/// Pure validation for content releases and bundled starter content.
final class ContentValidator {
  const ContentValidator(this.taxonomy);

  static final RegExp _exerciseIdPattern = RegExp(r'^raha_ex_[0-9]{6}$');
  static final RegExp _routineIdPattern = RegExp(r'^raha_rt_[0-9]{6}$');
  static final RegExp _mediaIdPattern = RegExp(r'^raha_media_[0-9]{6}$');
  static final RegExp _sha256Pattern = RegExp(r'^[a-f0-9]{64}$');
  static final RegExp _deliveryFilePattern = RegExp(
    r'^[a-z0-9_]+\.(mp4|gif|webp|jpg|jpeg|png)$',
  );

  final ContentTaxonomy taxonomy;

  ContentValidationResult validateExercise(Exercise exercise) {
    final errors = <ContentValidationError>[];
    if (!_exerciseIdPattern.hasMatch(exercise.id)) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidRahaId,
          exercise.id,
        ),
      );
    }
    _validateTranslations(exercise.translations, exercise.id, errors);
    _validateExerciseClassification(
      exercise.classification,
      exercise.id,
      errors,
    );

    final providerPairs = <String>{};
    for (final mapping in exercise.providerMappings) {
      if (!providerPairs.add(
        '${mapping.providerKey}\u0000${mapping.sourceExerciseId}',
      )) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.duplicateProviderMapping,
            exercise.id,
          ),
        );
      }
    }

    for (final media in exercise.mediaAssets) {
      _validateMedia(exercise, media, errors);
    }

    if (exercise.status == ContentStatus.published) {
      if (exercise.safetyReviewStatus != SafetyReviewStatus.approved) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.unpublishedExercise,
            exercise.id,
          ),
        );
      }
      final preferredPlayable = exercise.mediaAssets.where(
        (media) =>
            media.isPreferred &&
            media.status == ContentStatus.published &&
            _isPlayable(media),
      );
      if (preferredPlayable.length != 1) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.missingPreferredPlayableMedia,
            exercise.id,
          ),
        );
      }
    }
    return ContentValidationResult(List.unmodifiable(errors));
  }

  ContentValidationResult validateRoutine(
    Routine routine, {
    required Iterable<Exercise> exercises,
  }) {
    final errors = <ContentValidationError>[];
    if (!_routineIdPattern.hasMatch(routine.id)) {
      errors.add(
        ContentValidationError(ContentValidationCode.invalidRahaId, routine.id),
      );
    }
    _validateTranslations(routine.translations, routine.id, errors);
    _validateRoutineClassification(routine.classification, routine.id, errors);
    if (routine.estimatedDurationSeconds <= 0) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidRoutineDuration,
          routine.id,
        ),
      );
    }
    if (routine.version <= 0) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidRoutineVersion,
          routine.id,
        ),
      );
    }
    if (routine.steps.isEmpty) {
      errors.add(
        ContentValidationError(ContentValidationCode.emptyRoutine, routine.id),
      );
    }

    final exercisesById = {
      for (final exercise in exercises) exercise.id: exercise,
    };
    final positions = <int>{};
    for (final step in routine.steps) {
      if (step.position <= 0) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.invalidStepPosition,
            step.id,
          ),
        );
      } else if (!positions.add(step.position)) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.duplicateStepPosition,
            step.id,
          ),
        );
      }
      final hasDuration = step.durationSeconds != null;
      final hasRepetitions = step.repetitionCount != null;
      if (hasDuration == hasRepetitions ||
          (hasDuration && step.durationSeconds! <= 0) ||
          (hasRepetitions && step.repetitionCount! <= 0)) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.invalidStepMeasure,
            step.id,
          ),
        );
      }
      if (step.restAfterSeconds < 0) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.invalidStepRest,
            step.id,
          ),
        );
      }

      final exercise = exercisesById[step.exerciseId];
      if (exercise == null) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.unknownExercise,
            step.exerciseId,
          ),
        );
      } else if (routine.status == ContentStatus.published &&
          !_isPublishableExercise(exercise)) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.unpublishedExercise,
            step.exerciseId,
          ),
        );
      }
    }
    return ContentValidationResult(List.unmodifiable(errors));
  }

  void _validateTranslations(
    Map<String, dynamic> translations,
    String subject,
    List<ContentValidationError> errors,
  ) {
    for (final locale in const {'ar', 'en'}) {
      final translation = translations[locale];
      if (translation == null) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.missingRequiredLocale,
            subject,
          ),
        );
      } else if (translation.name.trim().isEmpty ||
          (translation is LocalizedRoutineContent &&
              translation.summary.trim().isEmpty)) {
        errors.add(
          ContentValidationError(
            ContentValidationCode.emptyLocalizedField,
            subject,
          ),
        );
      }
    }
  }

  void _validateExerciseClassification(
    ExerciseClassification classification,
    String subject,
    List<ContentValidationError> errors,
  ) {
    _validateKey(classification.category, taxonomy.categories, subject, errors);
    _validateKeys(
      classification.bodyAreas,
      taxonomy.bodyAreas,
      subject,
      errors,
    );
    _validateKeys(
      classification.equipment,
      taxonomy.equipment,
      subject,
      errors,
    );
    _validateKeys(
      classification.positions,
      taxonomy.positions,
      subject,
      errors,
    );
    _validateKeys(classification.goals, taxonomy.goals, subject, errors);
    _validateKeys(classification.contexts, taxonomy.contexts, subject, errors);
  }

  void _validateRoutineClassification(
    RoutineClassification classification,
    String subject,
    List<ContentValidationError> errors,
  ) {
    _validateKeys(
      classification.bodyAreas,
      taxonomy.bodyAreas,
      subject,
      errors,
    );
    _validateKeys(
      classification.equipment,
      taxonomy.equipment,
      subject,
      errors,
    );
    _validateKeys(
      classification.positions,
      taxonomy.positions,
      subject,
      errors,
    );
    _validateKeys(classification.goals, taxonomy.goals, subject, errors);
    _validateKeys(classification.contexts, taxonomy.contexts, subject, errors);
  }

  void _validateKey(
    String key,
    Set<String> allowedKeys,
    String subject,
    List<ContentValidationError> errors,
  ) {
    if (!allowedKeys.contains(key)) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidTaxonomyKey,
          subject,
        ),
      );
    }
  }

  void _validateKeys(
    Set<String> keys,
    Set<String> allowedKeys,
    String subject,
    List<ContentValidationError> errors,
  ) {
    for (final key in keys) {
      _validateKey(key, allowedKeys, subject, errors);
    }
  }

  void _validateMedia(
    Exercise exercise,
    MediaAsset media,
    List<ContentValidationError> errors,
  ) {
    if (!_mediaIdPattern.hasMatch(media.id) ||
        media.exerciseId != exercise.id) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidMediaReference,
          media.id,
        ),
      );
    }
    if (media.status == ContentStatus.published &&
        exercise.status != ContentStatus.published) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidMediaStatus,
          media.id,
        ),
      );
    }
    if (!_sha256Pattern.hasMatch(media.checksumSha256) ||
        !_deliveryFilePattern.hasMatch(media.deliveryFileName) ||
        media.deliveryFileName.contains('://') ||
        (media.width != null && media.width! <= 0) ||
        (media.height != null && media.height! <= 0) ||
        (media.durationMs != null && media.durationMs! <= 0)) {
      errors.add(
        ContentValidationError(
          ContentValidationCode.invalidMediaMetadata,
          media.id,
        ),
      );
    }
  }

  bool _isPublishableExercise(Exercise exercise) =>
      validateExercise(exercise).isValid &&
      exercise.status == ContentStatus.published;

  bool _isPlayable(MediaAsset media) =>
      media.type == MediaType.video || media.type == MediaType.animation;
}
