import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_service.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/check_in/data/drift_check_in_repository.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';
import 'package:raha_move/features/media/application/bundled_routine_media_preparer.dart';
import 'package:raha_move/features/preferences/domain/user_preferences.dart';
import 'package:raha_move/features/progress/data/drift_progress_repository.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/recommendations/data/drift_recommendation_catalog.dart';
import 'package:raha_move/features/recommendations/data/drift_recommendation_repository.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_config.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_engine.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_history.dart';
import 'package:raha_move/features/recommendations/domain/rules_recommendation_engine.dart';
import 'package:raha_move/features/routine_player/data/drift_routine_feedback_repository.dart';
import 'package:raha_move/features/routine_player/data/drift_routine_playback_loader.dart';
import 'package:raha_move/features/routine_player/data/drift_routine_session_repository.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';
import 'package:raha_move/features/sync/data/drift_sync_outbox_repository.dart';
import 'package:raha_move/features/sync/domain/backoff_policy.dart';
import 'package:raha_move/features/sync/domain/sync_operation.dart';
import 'package:raha_move/features/sync/domain/sync_transport.dart';
import 'package:raha_move/features/sync/domain/user_data_sync_engine.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'completes the bundled routine offline and syncs each action once',
    (tester) async {
      final now = DateTime.utc(2026, 9, 8, 12);
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final bootstrap = CatalogBootstrapService(
        repository: ContentReleaseRepository(database, clock: () => now),
        starterContent: BundledStarterContent(
          loadString: rootBundle.loadString,
        ),
        source: const _OfflineContentSource(),
        appVersion: '1.0.0',
      );
      final catalog = await bootstrap.run();
      expect(catalog.source, CatalogBootstrapSource.bundled);
      expect(catalog.errorCode, 'sync_unavailable');

      await database
          .into(database.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              userId: 'offline-user',
              preferredLocale: 'en',
              timezone: 'Asia/Riyadh',
              weeklyGoalDays: 3,
              localUpdatedAt: now,
            ),
          );
      const answers = CheckInAnswers(
        bodyState: BodyState.stiff,
        goalKey: 'ease_stiffness',
        bodyAreaKeys: {'neck'},
        availableMinutes: 5,
        positionKey: 'seated',
      );
      await DriftCheckInRepository(database, clock: () => now).save(
        userId: 'offline-user',
        checkInId: '10000000-0000-4000-8000-000000000001',
        startedAt: now,
        answers: answers,
      );

      final candidates = await DriftRecommendationCatalog(database)
          .loadPublishedCandidates();
      final recommendation = RulesRecommendationEngine()
          .recommend(
            RecommendationRequest(
              checkIn: answers,
              candidates: candidates,
              preferences: UserPreferences.initial(),
              history: RecommendationHistory.empty,
              config: RecommendationConfig.rulesV1,
              now: now,
              appVersion: '1.0.0',
            ),
          )
          .recommendations
          .single;
      expect(recommendation.routineId, 'raha_rt_000001');
      await DriftRecommendationRepository(database, clock: () => now).save(
        userId: 'offline-user',
        recommendationId: '10000000-0000-4000-8000-000000000002',
        checkInId: '10000000-0000-4000-8000-000000000001',
        routineId: recommendation.routineId,
        engineVersion: 'rules_v1',
        rank: recommendation.rank,
        score: recommendation.score,
        reasonCodes: recommendation.reasonCodes,
        scoreComponents: recommendation.scoreComponents,
        shownAt: now,
      );

      final plan = await DriftRoutinePlaybackLoader(database)
          .load(recommendation.routineId, 'en');
      final prepared = await BundledRoutineMediaPreparer().prepareForStart(
        plan.media,
        explicitUserStart: true,
      );
      expect(prepared.allReady, isTrue);

      final sessionId = '10000000-0000-4000-8000-000000000003';
      await DriftRoutineSessionRepository(database, clock: () => now).save(
        userId: 'offline-user',
        sessionId: sessionId,
        routineId: plan.routineId,
        routineVersion: plan.routineVersion,
        recommendationId: '10000000-0000-4000-8000-000000000002',
        startedAt: now,
        steps: [
          for (var index = 0; index < plan.steps.length; index++)
            RoutineStepSnapshot(
              stepId: plan.steps[index].stepId,
              exerciseId: plan.steps[index].exerciseId,
              position: index + 1,
              status: 'completed',
              targetDurationSeconds: plan.steps[index].durationSeconds,
              activeDurationSeconds: plan.steps[index].durationSeconds,
              skipRequested: false,
            ),
        ],
      );
      await DriftRoutineFeedbackRepository(database, clock: () => now).save(
        userId: 'offline-user',
        sessionId: sessionId,
        rating: FeedbackRating.littleBetter,
      );

      final provisional =
          await DriftProgressRepository(database, activeUserId: 'offline-user')
              .watchWeeklySummary(
                weekStart: const MovementDate(2026, 9, 7),
                locale: 'en',
              )
              .first;
      expect(provisional.completedRoutines, 1);
      expect(provisional.hasProvisionalProgress, isTrue);

      final outbox = DriftSyncOutboxRepository(
        database,
        activeUserId: 'offline-user',
        clock: () => now,
      );
      final offline = UserDataSyncEngine(
        outbox: outbox,
        transport: const _UnavailableTransport(),
        clock: () => now,
      );
      expect((await offline.synchronize()).skipped, greaterThan(0));
      expect(await outbox.dueOperations(), isNotEmpty);

      final recoveredTransport = _RecordingTransport();
      final recovered = UserDataSyncEngine(
        outbox: outbox,
        transport: recoveredTransport,
        backoff: const BackoffPolicy(baseDelay: Duration(seconds: 1)),
        clock: () => now,
      );
      final recovery = await recovered.synchronize();
      expect(recovery.hasFailures, isFalse);
      expect(await outbox.dueOperations(), isEmpty);
      expect(recoveredTransport.operationIds, hasLength(7));
      expect(recoveredTransport.operationIds.toSet(), hasLength(7));

      final verified =
          await DriftProgressRepository(database, activeUserId: 'offline-user')
              .watchWeeklySummary(
                weekStart: const MovementDate(2026, 9, 7),
                locale: 'en',
              )
              .first;
      expect(verified.completedRoutines, 1);
      expect(verified.hasProvisionalProgress, isFalse);
    },
  );
}

final class _OfflineContentSource implements ContentReleaseSource {
  const _OfflineContentSource();

  @override
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  }) => throw StateError('offline');
}

final class _UnavailableTransport implements SyncTransport {
  const _UnavailableTransport();

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async =>
      const SyncUnavailable();

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async => const SyncPullUnavailable();
}

final class _RecordingTransport implements SyncTransport {
  final operationIds = <String>[];

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async {
    operationIds.add(operation.operationId);
    return const SyncAccepted();
  }

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async => SyncPullSuccess(changes: const [], cursor: afterCursor);
}
