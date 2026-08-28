import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/exercise_library/domain/content_validation.dart';

import '../../../fixtures/content/content_fixture.dart';

void main() {
  const validator = ContentValidator(contentTaxonomy);

  group('provider-independent exercise content', () {
    test('preserves the Raha exercise identity when preferred media changes', () {
      const replacement = MediaAsset(
        id: 'raha_media_000002',
        exerciseId: 'raha_ex_000001',
        type: MediaType.video,
        mimeType: 'video/mp4',
        deliveryFileName: 'raha_ex_000001_provider_b_v2_720.mp4',
        checksumSha256:
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        status: ContentStatus.published,
        isPreferred: true,
        providerKey: 'provider_b',
        sourceExerciseId: 'unrelated-source-id',
      );
      final replaced = approvedExercise.copyWith(
        providerMappings: [
          const ProviderExerciseMapping(
            providerKey: 'provider_b',
            sourceExerciseId: 'unrelated-source-id',
          ),
        ],
        mediaAssets: [replacement],
      );

      expect(replaced.id, approvedExercise.id);
      expect(replaced.mediaAssets.single.providerKey, 'provider_b');
      expect(validator.validateExercise(replaced).isValid, isTrue);
    });

    test('supports multiple providers and media variants for one exercise', () {
      final exercise = approvedExercise.copyWith(
        providerMappings: [
          ...approvedExercise.providerMappings,
          const ProviderExerciseMapping(
            providerKey: 'provider_b',
            sourceExerciseId: 'source-2',
          ),
        ],
        mediaAssets: [
          approvedExercise.mediaAssets.single.copyWith(isPreferred: false),
          const MediaAsset(
            id: 'raha_media_000002',
            exerciseId: 'raha_ex_000001',
            type: MediaType.animation,
            mimeType: 'image/gif',
            deliveryFileName: 'raha_ex_000001_provider_b_v1_720.gif',
            checksumSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            status: ContentStatus.published,
            isPreferred: true,
            providerKey: 'provider_b',
            sourceExerciseId: 'source-2',
          ),
        ],
      );

      expect(exercise.mediaAssets, hasLength(2));
      expect(validator.validateExercise(exercise).isValid, isTrue);
    });
  });

  group('catalog publishability', () {
    test(
      'rejects a published routine whose exercise lacks safety approval',
      () {
        final unsafeExercise = approvedExercise.copyWith(
          safetyReviewStatus: SafetyReviewStatus.pending,
        );

        final result = validator.validateRoutine(
          approvedRoutine,
          exercises: [unsafeExercise],
        );

        expect(
          result.errors.map((error) => error.code),
          contains(ContentValidationCode.unpublishedExercise),
        );
      },
    );

    test('rejects a published exercise without exactly one preferred playable asset', () {
      final result = validator.validateExercise(
        approvedExercise.copyWith(
          mediaAssets: [
            approvedExercise.mediaAssets.single.copyWith(isPreferred: false),
          ],
        ),
      );

      expect(
        result.errors.map((error) => error.code),
        contains(ContentValidationCode.missingPreferredPlayableMedia),
      );
    });
  });

  group('routine validation', () {
    test('rejects non-positive and ambiguous step measures plus duplicate positions', () {
      final invalidRoutine = approvedRoutine.copyWith(
        steps: const [
          RoutineStep(
            id: 'raha_step_000001',
            exerciseId: 'raha_ex_000001',
            position: 1,
            durationSeconds: 0,
          ),
          RoutineStep(
            id: 'raha_step_000002',
            exerciseId: 'raha_ex_000001',
            position: 1,
            durationSeconds: 30,
            repetitionCount: 5,
          ),
        ],
      );

      final result = validator.validateRoutine(
        invalidRoutine,
        exercises: [approvedExercise],
      );

      expect(
        result.errors.map((error) => error.code),
        contains(ContentValidationCode.invalidStepMeasure),
      );
      expect(
        result.errors.map((error) => error.code),
        contains(ContentValidationCode.duplicateStepPosition),
      );
    });

    test('rejects taxonomy keys that have not been approved by Raha', () {
      final result = validator.validateExercise(
        approvedExercise.copyWith(
          classification: approvedExercise.classification.copyWith(
            bodyAreas: {'unreviewed_provider_label'},
          ),
        ),
      );

      expect(
        result.errors.map((error) => error.code),
        contains(ContentValidationCode.invalidTaxonomyKey),
      );
    });
  });

  group('serialization', () {
    test('round-trips Arabic and English exercise and routine content', () {
      final exerciseRoundTrip = Exercise.fromJson(approvedExercise.toJson());
      final routineRoundTrip = Routine.fromJson(approvedRoutine.toJson());

      expect(exerciseRoundTrip, approvedExercise);
      expect(routineRoundTrip, approvedRoutine);
      expect(exerciseRoundTrip.translations['ar']!.name, contains('الكتفين'));
      expect(
        routineRoundTrip.translations['en']!.name,
        'Seated shoulder reset',
      );
    });
  });
}
