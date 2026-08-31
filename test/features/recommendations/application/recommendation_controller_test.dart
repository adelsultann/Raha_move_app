import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/recommendations/application/recommendation_controller.dart';
import 'package:raha_move/features/recommendations/domain/recommendation_rejection.dart';

import '../support/recommendation_test_harness.dart';

void main() {
  test('recommends, persists a record, and returns the state', () async {
    final db = await seedRecommendationDatabase();
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    final state = await container.read(
      recommendationControllerProvider('check-in-1').future,
    );

    expect(state.selected, isNotNull);
    expect(state.selected!.routineId, 'raha_rt_000001');
    expect(state.selected!.rank, 0);
    expect(state.result.engineVersion, 'rules_v1');
    expect(state.recommendationId, isNotNull);

    final records = await db.select(db.localRecommendations).get();
    expect(records, hasLength(1));
    expect(records.single.routineId, 'raha_rt_000001');
    expect(records.single.checkInId, 'check-in-1');
    expect(records.single.engineVersion, 'rules_v1');
    expect(records.single.rank, 0);
  });

  test('returns an empty state when no candidate matches', () async {
    final db = await seedRecommendationDatabase(
      checkInAnswers: CheckInAnswers(
        bodyState: BodyState.stiff,
        goalKey: 'ease_stiffness',
        bodyAreaKeys: const {'neck'},
        availableMinutes: 5,
        // The only candidate is seated; requiring floor excludes it.
        positionKey: 'floor',
      ),
    );
    addTearDown(db.close);
    final container = buildRecommendationContainer(db);
    addTearDown(container.dispose);

    final state = await container.read(
      recommendationControllerProvider('check-in-1').future,
    );

    expect(state.selected, isNull);
    expect(state.recommendationId, isNull);

    final records = await db.select(db.localRecommendations).get();
    expect(records, isEmpty);
  });

  test(
    'rejecting "other" returns a different routine and records the rejection',
    () async {
      final db = await seedRecommendationDatabase(
        manifest: multiRoutineManifest(),
      );
      addTearDown(db.close);
      final container = buildRecommendationContainer(db);
      addTearDown(container.dispose);

      final provider = recommendationControllerProvider('check-in-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final initial = await container.read(provider.future);
      expect(initial.selected!.routineId, 'raha_rt_000001');

      await container
          .read(provider.notifier)
          .reject(RecommendationRejectionReason.other);

      final next = container.read(provider).requireValue;
      expect(next.selected!.routineId, 'raha_rt_000002');
      expect(next.selected!.routineId, isNot('raha_rt_000001'));

      final records = await db.select(db.localRecommendations).get();
      expect(records, hasLength(2));
      final rejected = records.firstWhere(
        (r) => r.routineId == 'raha_rt_000001',
      );
      expect(rejected.rejectionReason, 'other');
      expect(rejected.rejectedAt, isNotNull);
    },
  );

  test(
    'rejecting "too easy" shifts the difficulty to the intermediate routine',
    () async {
      final db = await seedRecommendationDatabase(
        manifest: multiRoutineManifest(),
      );
      addTearDown(db.close);
      final container = buildRecommendationContainer(db);
      addTearDown(container.dispose);

      final provider = recommendationControllerProvider('check-in-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final initial = await container.read(provider.future);
      expect(initial.selected!.routineId, 'raha_rt_000001');

      await container
          .read(provider.notifier)
          .reject(RecommendationRejectionReason.tooEasy);

      final next = container.read(provider).requireValue;
      expect(next.selected!.routineId, 'raha_rt_000003');
      expect(next.refinement.difficultyOverride, DifficultyLevel.intermediate);
    },
  );

  test(
    'the rejection loop terminates when all candidates are rejected',
    () async {
      final db = await seedRecommendationDatabase(
        manifest: multiRoutineManifest(),
      );
      addTearDown(db.close);
      final container = buildRecommendationContainer(db);
      addTearDown(container.dispose);

      final provider = recommendationControllerProvider('check-in-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(provider.notifier);
      await container.read(provider.future);

      var state = container.read(provider).requireValue;
      var rejects = 0;
      while (state.selected != null && rejects < 10) {
        await notifier.reject(RecommendationRejectionReason.other);
        state = container.read(provider).requireValue;
        rejects += 1;
      }

      expect(rejects, 3); // three routines, all rejected
      expect(state.selected, isNull);
      expect(state.hasNoAlternative, isTrue);
    },
  );
}
