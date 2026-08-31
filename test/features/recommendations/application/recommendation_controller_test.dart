import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/recommendations/application/recommendation_controller.dart';

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
}
