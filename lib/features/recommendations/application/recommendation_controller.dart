import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap/catalog_bootstrap_providers.dart';
import '../../../core/database/app_database.dart' show generateUuidV4;
import '../../authentication/application/auth_controller.dart';
import '../../check_in/application/check_in_providers.dart';
import '../../exercise_library/domain/content_models.dart';
import '../../preferences/application/preferences_providers.dart';
import '../../preferences/domain/user_preferences.dart';
import '../domain/recommendation_candidate.dart';
import '../domain/recommendation_config.dart';
import '../domain/recommendation_engine.dart';
import '../domain/recommendation_rejection.dart';
import 'recommendation_providers.dart';
import 'recommendation_state.dart';

part 'recommendation_controller.g.dart';

/// Orchestrates one recommendation flow for a completed check-in, including the
/// alternative/rejection loop: it reads the check-in back from local storage,
/// loads candidates/history/preferences, runs the on-device engine, and
/// persists the top candidate. Rejecting a recommendation marks it rejected,
/// accumulates a refinement, and re-runs deterministically until no alternative
/// remains (the rejected set grows, so the loop cannot run indefinitely).
@riverpod
class RecommendationController extends _$RecommendationController {
  late String _checkInId;
  String? _userId;
  List<RecommendationCandidate> _candidates = const [];
  RecommendationRefinement _refinement = RecommendationRefinement.initial;

  @override
  Future<RecommendationState> build(String checkInId) async {
    _checkInId = checkInId;
    _userId = null;
    _candidates = const [];
    _refinement = RecommendationRefinement.initial;
    return _recommend();
  }

  Future<RecommendationState> _recommend() async {
    final auth = await ref.read(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) {
      throw StateError('RecommendationController requires an active user id');
    }
    _userId = userId;

    final checkIn = await ref
        .read(checkInRepositoryProvider)
        .read(userId, _checkInId);
    if (checkIn == null) {
      throw const RecommendationUnavailableException();
    }

    final candidates = await ref
        .read(recommendationCatalogProvider)
        .loadPublishedCandidates();
    _candidates = candidates;
    final history = await ref
        .read(recommendationHistoryProvider)
        .loadFor(userId);
    final preferences =
        await ref.read(preferencesRepositoryProvider).read(userId) ??
        UserPreferences.initial();

    final result = ref
        .read(recommendationEngineProvider)
        .recommend(
          RecommendationRequest(
            checkIn: checkIn,
            candidates: candidates,
            preferences: preferences,
            history: history,
            config: RecommendationConfig.rulesV1,
            now: DateTime.now().toUtc(),
            appVersion: ref.read(appVersionProvider),
            refinement: _refinement,
          ),
        );

    if (result.isEmpty) {
      return RecommendationState(
        checkIn: checkIn,
        result: result,
        refinement: _refinement,
      );
    }

    final top = result.recommendations.first;
    final recommendationId = generateUuidV4();
    await ref
        .read(recommendationRepositoryProvider)
        .save(
          userId: userId,
          recommendationId: recommendationId,
          checkInId: _checkInId,
          routineId: top.routineId,
          engineVersion: result.engineVersion,
          rank: top.rank,
          score: top.score,
          reasonCodes: top.reasonCodes,
          scoreComponents: top.scoreComponents,
          shownAt: DateTime.now().toUtc(),
        );

    return RecommendationState(
      checkIn: checkIn,
      result: result,
      recommendationId: recommendationId,
      refinement: _refinement,
    );
  }

  /// Rejects the currently selected recommendation and re-recommends with the
  /// accumulated refinement. No-op when there is nothing to reject. Any failure
  /// surfaces as an [AsyncError] so the screen shows a recoverable retry state
  /// rather than an unhandled exception.
  Future<void> reject(RecommendationRejectionReason reason) async {
    try {
      final current = state.value;
      if (current == null) return;
      final selected = current.selected;
      final recommendationId = current.recommendationId;
      if (selected == null || recommendationId == null || _userId == null) {
        return;
      }

      await ref
          .read(recommendationRepositoryProvider)
          .reject(
            userId: _userId!,
            recommendationId: recommendationId,
            reason: reason.key,
            rejectedAt: DateTime.now().toUtc(),
          );

      final rejectedCandidate = _findCandidate(selected.routineId);
      final preferences =
          await ref.read(preferencesRepositoryProvider).read(_userId!) ??
          UserPreferences.initial();
      final experienceDifficulty = DifficultyLevel.values.byName(
        preferences.experienceLevel.code,
      );

      _refinement = refineAfterRejection(
        current: _refinement,
        reason: reason,
        rejected: rejectedCandidate ?? _fallbackCandidate(selected.routineId),
        experienceDifficulty: experienceDifficulty,
      );

      final next = await _recommend();
      state = AsyncData(next);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  RecommendationCandidate? _findCandidate(String routineId) {
    for (final candidate in _candidates) {
      if (candidate.routineId == routineId) return candidate;
    }
    return null;
  }

  /// A last-resort candidate snapshot used only if the selected routine can no
  /// longer be resolved from the loaded catalog. It carries no taxonomy, so a
  /// constraint reason only excludes the routine id, which is still safe and
  /// terminating.
  RecommendationCandidate _fallbackCandidate(String routineId) =>
      RecommendationCandidate(
        routineId: routineId,
        status: ContentStatus.published,
        accessTier: AccessTier.free,
        difficulty: DifficultyLevel.beginner,
        estimatedDurationSeconds: 0,
        bodyAreas: const {},
        goals: const {},
        positions: const {},
        exerciseIds: const {},
        exercisesSafetyApproved: true,
        exercisesHavePlayableMedia: true,
      );
}

/// Thrown when the referenced check-in or recommended routine content cannot be
/// resolved, so the presentation layer can show a recoverable retry state
/// instead of a broken screen.
final class RecommendationUnavailableException implements Exception {
  const RecommendationUnavailableException();
}
