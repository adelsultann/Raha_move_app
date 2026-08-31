import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/preferences/domain/experience_level.dart';
import 'package:raha_move/features/preferences/domain/movement_position.dart';
import 'package:raha_move/features/preferences/domain/user_preferences.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_candidate.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_config.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_engine.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_history.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_rejection.dart';
import 'package:raha_move/features/recommendations/domain/rules_recommendation_engine.dart';

void main() {
  const engine = RulesRecommendationEngine();
  final now = DateTime.utc(2026, 8, 30, 12);

  RecommendationCandidate candidate({
    String id = 'raha_rt_000001',
    ContentStatus status = ContentStatus.published,
    AccessTier accessTier = AccessTier.free,
    DifficultyLevel difficulty = DifficultyLevel.beginner,
    int durationSeconds = 300,
    Set<String> bodyAreas = const {'neck', 'shoulders'},
    Set<String> goals = const {'ease_stiffness'},
    Set<String> positions = const {'seated'},
    Set<String> exerciseIds = const {'raha_ex_000001'},
    bool safetyApproved = true,
    bool hasPlayableMedia = true,
    String? minimumAppVersion,
  }) => RecommendationCandidate(
    routineId: id,
    status: status,
    accessTier: accessTier,
    difficulty: difficulty,
    estimatedDurationSeconds: durationSeconds,
    bodyAreas: bodyAreas,
    goals: goals,
    positions: positions,
    exerciseIds: exerciseIds,
    exercisesSafetyApproved: safetyApproved,
    exercisesHavePlayableMedia: hasPlayableMedia,
    minimumAppVersion: minimumAppVersion,
  );

  CheckInAnswers answers({
    String goalKey = 'ease_stiffness',
    Set<String> bodyAreaKeys = const {'neck', 'shoulders'},
    int minutes = 5,
    String? positionKey = 'seated',
  }) => CheckInAnswers(
    bodyState: BodyState.stiff,
    goalKey: goalKey,
    bodyAreaKeys: bodyAreaKeys,
    availableMinutes: minutes,
    positionKey: positionKey,
  );

  const preferences = UserPreferences(
    experienceLevel: ExperienceLevel.beginner,
    preferredPositions: {MovementPosition.seated},
    weeklyGoalDays: 3,
  );

  RecommendationRequest request({
    CheckInAnswers? checkIn,
    List<RecommendationCandidate> candidates = const [],
    UserPreferences prefs = preferences,
    RecommendationHistory history = RecommendationHistory.empty,
    RecommendationConfig config = RecommendationConfig.rulesV1,
    DateTime? at,
    bool hasPremiumAccess = false,
    RecommendationRefinement refinement = RecommendationRefinement.initial,
  }) => RecommendationRequest(
    checkIn: checkIn ?? answers(),
    candidates: candidates,
    preferences: prefs,
    history: history,
    config: config,
    now: at ?? now,
    appVersion: '1.0.0',
    hasPremiumAccess: hasPremiumAccess,
    refinement: refinement,
  );

  test('exact match scores every factor and records components + reasons', () {
    final result = engine.recommend(request(candidates: [candidate()]));

    expect(result.engineVersion, 'rules_v1');
    expect(result.recommendations, hasLength(1));

    final top = result.recommendations.single;
    expect(top.routineId, 'raha_rt_000001');
    expect(top.rank, 0);
    // 40*2 + 25 + 20 + 15 + 10 = 150
    expect(top.score, 150);
    expect(top.scoreComponents, {
      RecommendationScoreComponent.bodyAreaMatch: 80,
      RecommendationScoreComponent.goalMatch: 25,
      RecommendationScoreComponent.timeFit: 20,
      RecommendationScoreComponent.positionPreference: 15,
      RecommendationScoreComponent.difficultyMatch: 10,
    });
    expect(top.reasonCodes, [
      RecommendationReasonCode.bodyAreaMatch,
      RecommendationReasonCode.goalMatch,
      RecommendationReasonCode.timeFit,
      RecommendationReasonCode.positionPreference,
      RecommendationReasonCode.difficultyMatch,
    ]);
  });

  test('partial match (fewer body areas) ranks below a fuller match', () {
    final result = engine.recommend(
      request(
        candidates: [
          candidate(id: 'raha_rt_000002', bodyAreas: const {'neck'}),
          candidate(id: 'raha_rt_000001'), // both neck + shoulders
        ],
      ),
    );

    expect(result.recommendations.map((r) => r.routineId).toList(), [
      'raha_rt_000001',
      'raha_rt_000002',
    ]);
    expect(result.recommendations[1].score, 110); // 40 + 25 + 20 + 15 + 10
  });

  test('multiple body areas scale the body-area component', () {
    final one = engine
        .recommend(
          request(
            candidates: [
              candidate(bodyAreas: const {'neck'}),
            ],
          ),
        )
        .recommendations
        .single;
    final three = engine
        .recommend(
          request(
            checkIn: answers(bodyAreaKeys: const {'neck', 'shoulders', 'hips'}),
            candidates: [
              candidate(bodyAreas: const {'neck', 'shoulders', 'hips'}),
            ],
          ),
        )
        .recommendations
        .single;

    expect(one.scoreComponents[RecommendationScoreComponent.bodyAreaMatch], 40);
    expect(
      three.scoreComponents[RecommendationScoreComponent.bodyAreaMatch],
      120,
    );
  });

  group('exclusions before scoring', () {
    test('incompatible position', () {
      final result = engine.recommend(
        request(
          checkIn: answers(positionKey: 'seated'),
          candidates: [
            candidate(positions: const {'standing'}),
          ],
        ),
      );
      expect(result.isEmpty, isTrue);
    });

    test('position is not excluded when the check-in allows any', () {
      final result = engine.recommend(
        request(
          checkIn: answers(positionKey: null),
          candidates: [
            candidate(positions: const {'standing'}),
          ],
        ),
      );
      expect(result.isEmpty, isFalse);
    });

    test('not safety-approved', () {
      final result = engine.recommend(
        request(candidates: [candidate(safetyApproved: false)]),
      );
      expect(result.isEmpty, isTrue);
    });

    test('no playable media', () {
      final result = engine.recommend(
        request(candidates: [candidate(hasPlayableMedia: false)]),
      );
      expect(result.isEmpty, isTrue);
    });

    test('not published', () {
      final result = engine.recommend(
        request(candidates: [candidate(status: ContentStatus.retired)]),
      );
      expect(result.isEmpty, isTrue);
    });

    test('premium without entitlement', () {
      final result = engine.recommend(
        request(candidates: [candidate(accessTier: AccessTier.premium)]),
      );
      expect(result.isEmpty, isTrue);
    });

    test('premium is eligible with entitlement', () {
      final result = engine.recommend(
        request(
          candidates: [candidate(accessTier: AccessTier.premium)],
          hasPremiumAccess: true,
        ),
      );
      expect(result.isEmpty, isFalse);
    });

    test('requires a newer app version', () {
      final result = engine.recommend(
        request(candidates: [candidate(minimumAppVersion: '2.0.0')]),
      );
      expect(result.isEmpty, isTrue);
    });

    test('exceeds the selected time', () {
      final result = engine.recommend(
        request(
          checkIn: answers(minutes: 3),
          candidates: [candidate(durationSeconds: 300)],
        ),
      );
      expect(result.isEmpty, isTrue);
    });

    test('a configured tolerance permits a small overshoot', () {
      final tolerant = RecommendationConfig.rulesV1.copyWith(
        maxDurationOvershootSeconds: 30,
      );
      final result = engine.recommend(
        request(
          checkIn: answers(minutes: 5), // 300 seconds
          candidates: [candidate(durationSeconds: 315)],
          config: tolerant,
        ),
      );
      expect(result.isEmpty, isFalse);
    });
  });

  test('no candidates produces an empty result', () {
    final result = engine.recommend(request(candidates: const []));
    expect(result.isEmpty, isTrue);
    expect(result.recommendations, isEmpty);
  });

  test('recent completion applies a penalty and reason', () {
    final history = RecommendationHistory(
      recentAttempts: [
        RecentRoutineAttempt(
          routineId: 'raha_rt_000001',
          completedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
    );
    final result = engine.recommend(
      request(candidates: [candidate()], history: history),
    );

    final top = result.recommendations.single;
    expect(top.score, 140); // 150 - 10
    expect(
      top.scoreComponents[RecommendationScoreComponent.recencyPenalty],
      -10,
    );
    expect(
      top.reasonCodes,
      contains(RecommendationReasonCode.recentCompletion),
    );
  });

  test('completion outside the window does not penalize', () {
    final history = RecommendationHistory(
      recentAttempts: [
        RecentRoutineAttempt(
          routineId: 'raha_rt_000001',
          completedAt: now.subtract(const Duration(days: 30)),
        ),
      ],
    );
    final result = engine.recommend(
      request(candidates: [candidate()], history: history),
    );
    expect(result.recommendations.single.score, 150);
  });

  test('previous discomfort applies a penalty and reason', () {
    final history = RecommendationHistory(
      uncomfortableExerciseIds: const {'raha_ex_000001'},
    );
    final result = engine.recommend(
      request(candidates: [candidate()], history: history),
    );

    final top = result.recommendations.single;
    expect(top.score, 130); // 150 - 20
    expect(
      top.scoreComponents[RecommendationScoreComponent.discomfortPenalty],
      -20,
    );
    expect(
      top.reasonCodes,
      contains(RecommendationReasonCode.previousDiscomfort),
    );
  });

  group('deterministic tie-breaking', () {
    test('same score prefers the fuller routine duration', () {
      final noTimeWeight = RecommendationConfig.rulesV1.copyWith(
        timeMatchWeight: 0,
      );
      final result = engine.recommend(
        request(
          candidates: [
            candidate(id: 'raha_rt_short', durationSeconds: 240),
            candidate(id: 'raha_rt_long', durationSeconds: 300),
          ],
          config: noTimeWeight,
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_long',
        'raha_rt_short',
      ]);
    });

    test('exact tie breaks by stable routine id ascending', () {
      final noTimeWeight = RecommendationConfig.rulesV1.copyWith(
        timeMatchWeight: 0,
      );
      final result = engine.recommend(
        request(
          candidates: [
            candidate(id: 'raha_rt_000002'),
            candidate(id: 'raha_rt_000001'),
          ],
          config: noTimeWeight,
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_000001',
        'raha_rt_000002',
      ]);
    });

    test('equal score prefers the candidate matching more body areas', () {
      final config = RecommendationConfig.rulesV1.copyWith(
        goalMatchWeight: 40,
        timeMatchWeight: 0,
        positionPreferenceWeight: 0,
        difficultyMatchWeight: 0,
      );
      final result = engine.recommend(
        request(
          candidates: [
            // 1 matched area + goal = 80
            candidate(id: 'raha_rt_single', bodyAreas: const {'neck'}),
            // 2 matched areas, no goal = 80
            candidate(
              id: 'raha_rt_double',
              bodyAreas: const {'neck', 'shoulders'},
              goals: const {'relax'},
            ),
          ],
          config: config,
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_double',
        'raha_rt_single',
      ]);
    });

    test('equal score and areas prefers the candidate matching the goal', () {
      final config = RecommendationConfig.rulesV1.copyWith(
        goalMatchWeight: 0,
        timeMatchWeight: 0,
        positionPreferenceWeight: 0,
        difficultyMatchWeight: 0,
      );
      final result = engine.recommend(
        request(
          candidates: [
            candidate(
              id: 'raha_rt_nogoal',
              bodyAreas: const {'neck'},
              goals: const {'relax'},
            ),
            candidate(id: 'raha_rt_goal', bodyAreas: const {'neck'}),
          ],
          config: config,
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_goal',
        'raha_rt_nogoal',
      ]);
    });
  });

  group('refinement', () {
    test('a rejected routine is excluded', () {
      final result = engine.recommend(
        request(
          candidates: [
            candidate(id: 'raha_rt_000001'),
            candidate(id: 'raha_rt_000002'),
          ],
          refinement: RecommendationRefinement(
            rejectedRoutineIds: const {'raha_rt_000001'},
          ),
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_000002',
      ]);
    });

    test('all rejected routines produce an empty result', () {
      final result = engine.recommend(
        request(
          candidates: [
            candidate(id: 'raha_rt_000001'),
            candidate(id: 'raha_rt_000002'),
          ],
          refinement: RecommendationRefinement(
            rejectedRoutineIds: const {'raha_rt_000001', 'raha_rt_000002'},
          ),
        ),
      );
      expect(result.isEmpty, isTrue);
    });

    test('an excluded position filters out the routine', () {
      final result = engine.recommend(
        request(
          checkIn: answers(positionKey: null),
          candidates: [
            candidate(id: 'raha_rt_seated', positions: const {'seated'}),
            candidate(id: 'raha_rt_floor', positions: const {'floor'}),
          ],
          refinement: RecommendationRefinement(
            excludedPositionKeys: const {'seated'},
          ),
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_floor',
      ]);
    });

    test('an excluded body area filters out the routine', () {
      final result = engine.recommend(
        request(
          candidates: [
            candidate(id: 'raha_rt_neck', bodyAreas: const {'neck'}),
            candidate(id: 'raha_rt_shoulders', bodyAreas: const {'shoulders'}),
          ],
          refinement: RecommendationRefinement(
            excludedBodyAreaKeys: const {'neck'},
          ),
        ),
      );
      expect(result.recommendations.map((r) => r.routineId).toList(), [
        'raha_rt_shoulders',
      ]);
    });

    test('a difficulty override shifts the preferred difficulty', () {
      final beginner = candidate(
        id: 'raha_rt_beginner',
        difficulty: DifficultyLevel.beginner,
        bodyAreas: const {'neck'},
      );
      final intermediate = candidate(
        id: 'raha_rt_intermediate',
        difficulty: DifficultyLevel.intermediate,
        bodyAreas: const {'neck'},
      );

      final baseline = engine.recommend(
        request(candidates: [beginner, intermediate]),
      );
      expect(baseline.recommendations.first.routineId, 'raha_rt_beginner');

      final overridden = engine.recommend(
        request(
          candidates: [beginner, intermediate],
          refinement: RecommendationRefinement(
            difficultyOverride: DifficultyLevel.intermediate,
          ),
        ),
      );
      expect(
        overridden.recommendations.first.routineId,
        'raha_rt_intermediate',
      );
    });
  });

  test('same inputs always produce the same result', () {
    RecommendationResult build() => engine.recommend(
      request(
        candidates: [
          candidate(id: 'raha_rt_000001'),
          candidate(id: 'raha_rt_000002', bodyAreas: const {'neck'}),
        ],
      ),
    );

    final first = build();
    final second = build();

    expect(first.engineVersion, second.engineVersion);
    expect(first.recommendations, second.recommendations);
  });
}
