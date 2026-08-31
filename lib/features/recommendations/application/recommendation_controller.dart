import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap/catalog_bootstrap_providers.dart';
import '../../../core/database/app_database.dart' show generateUuidV4;
import '../../authentication/application/auth_controller.dart';
import '../../check_in/application/check_in_providers.dart';
import '../../preferences/application/preferences_providers.dart';
import '../../preferences/domain/user_preferences.dart';
import '../domain/recommendation_config.dart';
import '../domain/recommendation_engine.dart';
import 'recommendation_providers.dart';
import 'recommendation_state.dart';

part 'recommendation_controller.g.dart';

/// Orchestrates one recommendation flow for a completed check-in: it reads the
/// check-in back from local storage, loads candidates/history/preferences, runs
/// the on-device engine, and persists the top candidate as a recommendation
/// record. It is a pure orchestration layer — determinism lives in the engine.
@riverpod
class RecommendationController extends _$RecommendationController {
  @override
  Future<RecommendationState> build(String checkInId) async {
    final auth = await ref.watch(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) {
      throw StateError('RecommendationController requires an active user id');
    }

    final checkIn = await ref
        .read(checkInRepositoryProvider)
        .read(userId, checkInId);
    if (checkIn == null) {
      throw const RecommendationUnavailableException();
    }

    final candidates = await ref
        .read(recommendationCatalogProvider)
        .loadPublishedCandidates();
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
          ),
        );

    if (result.isEmpty) {
      return RecommendationState(checkIn: checkIn, result: result);
    }

    final top = result.recommendations.first;
    final recommendationId = generateUuidV4();
    await ref
        .read(recommendationRepositoryProvider)
        .save(
          userId: userId,
          recommendationId: recommendationId,
          checkInId: checkInId,
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
    );
  }
}

/// Thrown when the referenced check-in or recommended routine content cannot be
/// resolved, so the presentation layer can show a recoverable retry state
/// instead of a broken screen.
final class RecommendationUnavailableException implements Exception {
  const RecommendationUnavailableException();
}
