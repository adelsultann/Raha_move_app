import '../../../core/utilities/semantic_version.dart';
import '../../exercise_library/domain/content_models.dart';
import '../../preferences/domain/experience_level.dart';
import 'recommendation_candidate.dart';
import 'recommendation_engine.dart';

/// The deterministic, on-device rules engine for `rules_v1` and later.
///
/// It is a pure function of [RecommendationRequest]: it never reads the system
/// clock, Drift, Supabase, media, or Flutter. Filtering, scoring, and
/// tie-breaking are driven entirely by the request's versioned
/// [RecommendationConfig], so the same inputs always produce the same result.
final class RulesRecommendationEngine implements RoutineRecommendationEngine {
  const RulesRecommendationEngine();

  @override
  RecommendationResult recommend(RecommendationRequest request) {
    final availableSeconds = request.checkIn.availableMinutes * 60;
    final runningVersion = SemanticVersion.tryParse(request.appVersion);

    final ranked = <_RankedCandidate>[];
    for (final candidate in request.candidates) {
      if (_isExcluded(candidate, request, availableSeconds, runningVersion)) {
        continue;
      }
      ranked.add(_score(candidate, request, availableSeconds));
    }

    ranked.sort(_compare);

    final recommendations = <ScoredRoutine>[
      for (var i = 0; i < ranked.length; i++)
        ScoredRoutine(
          routineId: ranked[i].routineId,
          rank: i,
          score: ranked[i].score,
          scoreComponents: Map.unmodifiable(ranked[i].scoreComponents),
          reasonCodes: List.unmodifiable(ranked[i].reasonCodes),
        ),
    ];

    return RecommendationResult(
      engineVersion: request.config.version,
      recommendations: List.unmodifiable(recommendations),
    );
  }

  bool _isExcluded(
    RecommendationCandidate candidate,
    RecommendationRequest request,
    int availableSeconds,
    SemanticVersion? runningVersion,
  ) {
    // Availability: only published routines are eligible.
    if (candidate.status != ContentStatus.published) return true;

    // Safety: every referenced exercise must be safety-approved.
    if (!candidate.exercisesSafetyApproved) return true;

    // Playability: a routine you cannot play is not available.
    if (!candidate.exercisesHavePlayableMedia) return true;

    // Position: the check-in's required position (null means "any").
    final positionKey = request.checkIn.positionKey;
    if (positionKey != null && !candidate.positions.contains(positionKey)) {
      return true;
    }

    // Access: premium candidates require premium entitlement.
    if (candidate.accessTier == AccessTier.premium &&
        !request.hasPremiumAccess) {
      return true;
    }

    // App version: a candidate that needs a newer app is excluded.
    final minimum = SemanticVersion.tryParse(candidate.minimumAppVersion);
    if (minimum != null &&
        (runningVersion == null || minimum.compareTo(runningVersion) > 0)) {
      return true;
    }

    // Time: never exceed the selected time beyond the configured tolerance.
    final allowed =
        availableSeconds + request.config.maxDurationOvershootSeconds;
    if (candidate.estimatedDurationSeconds > allowed) return true;

    return false;
  }

  _RankedCandidate _score(
    RecommendationCandidate candidate,
    RecommendationRequest request,
    int availableSeconds,
  ) {
    final config = request.config;
    final components = <String, int>{};
    final reasons = <String>[];

    final matchedAreas = request.checkIn.bodyAreaKeys
        .where(candidate.bodyAreas.contains)
        .length;
    if (matchedAreas > 0) {
      components[RecommendationScoreComponent.bodyAreaMatch] =
          config.bodyAreaMatchWeight * matchedAreas;
      reasons.add(RecommendationReasonCode.bodyAreaMatch);
    }

    if (candidate.goals.contains(request.checkIn.goalKey)) {
      components[RecommendationScoreComponent.goalMatch] =
          config.goalMatchWeight;
      reasons.add(RecommendationReasonCode.goalMatch);
    }

    final timeScore =
        ((config.timeMatchWeight * candidate.estimatedDurationSeconds) ~/
                availableSeconds)
            .clamp(0, config.timeMatchWeight);
    if (timeScore > 0) {
      components[RecommendationScoreComponent.timeFit] = timeScore;
      reasons.add(RecommendationReasonCode.timeFit);
    }

    if (request.preferences.preferredPositions.isNotEmpty &&
        request.preferences.preferredPositions
            .map((position) => position.key)
            .any(candidate.positions.contains)) {
      components[RecommendationScoreComponent.positionPreference] =
          config.positionPreferenceWeight;
      reasons.add(RecommendationReasonCode.positionPreference);
    }

    if (candidate.difficulty ==
        _difficultyFor(request.preferences.experienceLevel)) {
      components[RecommendationScoreComponent.difficultyMatch] =
          config.difficultyMatchWeight;
      reasons.add(RecommendationReasonCode.difficultyMatch);
    }

    final cutoff = request.now.subtract(
      Duration(days: config.recencyWindowDays),
    );
    final recentlyCompleted = request.history.recentAttempts.any(
      (attempt) =>
          attempt.routineId == candidate.routineId &&
          !attempt.completedAt.isAfter(request.now) &&
          !attempt.completedAt.isBefore(cutoff),
    );
    if (recentlyCompleted) {
      components[RecommendationScoreComponent.recencyPenalty] =
          -config.recencyPenaltyWeight;
      reasons.add(RecommendationReasonCode.recentCompletion);
    }

    final hasDiscomfort = candidate.exerciseIds.any(
      request.history.uncomfortableExerciseIds.contains,
    );
    if (hasDiscomfort) {
      components[RecommendationScoreComponent.discomfortPenalty] =
          -config.discomfortPenaltyWeight;
      reasons.add(RecommendationReasonCode.previousDiscomfort);
    }

    final score = components.values.fold(0, (sum, value) => sum + value);
    return _RankedCandidate(
      routineId: candidate.routineId,
      score: score,
      scoreComponents: components,
      reasonCodes: reasons,
      matchedAreaCount: matchedAreas,
      goalMatched: candidate.goals.contains(request.checkIn.goalKey),
      durationSeconds: candidate.estimatedDurationSeconds,
    );
  }

  static DifficultyLevel _difficultyFor(ExperienceLevel level) =>
      DifficultyLevel.values.byName(level.code);

  /// Deterministic total order used both for ranking and for the tie-break
  /// order required by RAHA-041:
  ///
  ///  1. Higher total score first.
  ///  2. More matched body areas first.
  ///  3. Goal match before no goal match.
  ///  4. Longer duration first (prefer the routine that better fills the time).
  ///  5. Stable routine id ascending (final deterministic tie-break).
  static int _compare(_RankedCandidate a, _RankedCandidate b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byAreas = b.matchedAreaCount.compareTo(a.matchedAreaCount);
    if (byAreas != 0) return byAreas;
    final byGoal = (b.goalMatched ? 1 : 0).compareTo(a.goalMatched ? 1 : 0);
    if (byGoal != 0) return byGoal;
    final byDuration = b.durationSeconds.compareTo(a.durationSeconds);
    if (byDuration != 0) return byDuration;
    return a.routineId.compareTo(b.routineId);
  }
}

/// Internal pre-sort candidate carrying the tie-break signals.
final class _RankedCandidate {
  const _RankedCandidate({
    required this.routineId,
    required this.score,
    required this.scoreComponents,
    required this.reasonCodes,
    required this.matchedAreaCount,
    required this.goalMatched,
    required this.durationSeconds,
  });

  final String routineId;
  final int score;
  final Map<String, int> scoreComponents;
  final List<String> reasonCodes;
  final int matchedAreaCount;
  final bool goalMatched;
  final int durationSeconds;
}
