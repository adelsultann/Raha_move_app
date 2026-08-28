import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/exercise_library/domain/content_validation.dart';

const contentTaxonomy = ContentTaxonomy(
  categories: {'mobility'},
  bodyAreas: {'neck', 'shoulders'},
  equipment: {'body_weight'},
  positions: {'seated'},
  goals: {'ease_stiffness'},
  contexts: {'everyday_mobility'},
);

const approvedExercise = Exercise(
  id: 'raha_ex_000001',
  status: ContentStatus.published,
  accessTier: AccessTier.free,
  difficulty: DifficultyLevel.beginner,
  safetyReviewStatus: SafetyReviewStatus.approved,
  translations: {
    'en': LocalizedExerciseContent(
      name: 'Seated shoulder circles',
      description: 'A controlled seated shoulder movement.',
    ),
    'ar': LocalizedExerciseContent(
      name: 'دوائر الكتفين أثناء الجلوس',
      description: 'حركة كتفين متحكم بها أثناء الجلوس.',
    ),
  },
  classification: ExerciseClassification(
    category: 'mobility',
    bodyAreas: {'shoulders'},
    equipment: {'body_weight'},
    positions: {'seated'},
    goals: {'ease_stiffness'},
    contexts: {'everyday_mobility'},
  ),
  providerMappings: [
    ProviderExerciseMapping(
      providerKey: 'provider_a',
      sourceExerciseId: 'source-1',
    ),
  ],
  mediaAssets: [
    MediaAsset(
      id: 'raha_media_000001',
      exerciseId: 'raha_ex_000001',
      type: MediaType.video,
      mimeType: 'video/mp4',
      deliveryFileName: 'raha_ex_000001_provider_a_v1_720.mp4',
      checksumSha256:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      status: ContentStatus.published,
      isPreferred: true,
      providerKey: 'provider_a',
      sourceExerciseId: 'source-1',
      sourceFileName: 'source-1.mp4',
      width: 720,
      height: 720,
      durationMs: 5000,
    ),
  ],
);

const approvedRoutine = Routine(
  id: 'raha_rt_000001',
  status: ContentStatus.published,
  accessTier: AccessTier.free,
  difficulty: DifficultyLevel.beginner,
  estimatedDurationSeconds: 60,
  version: 1,
  translations: {
    'en': LocalizedRoutineContent(
      name: 'Seated shoulder reset',
      summary: 'A short seated mobility routine.',
    ),
    'ar': LocalizedRoutineContent(
      name: 'استراحة للكتفين أثناء الجلوس',
      summary: 'روتين حركة قصير أثناء الجلوس.',
    ),
  },
  classification: RoutineClassification(
    bodyAreas: {'shoulders'},
    goals: {'ease_stiffness'},
    positions: {'seated'},
    equipment: {'body_weight'},
    contexts: {'everyday_mobility'},
  ),
  steps: [
    RoutineStep(
      id: 'raha_step_000001',
      exerciseId: 'raha_ex_000001',
      position: 1,
      durationSeconds: 60,
    ),
  ],
);
