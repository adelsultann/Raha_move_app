import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/sync/domain/sync_priority.dart';

void main() {
  test('parents flush before children in dependency order', () {
    expect(
      syncPriorityForKind('check_in_upsert'),
      lessThan(syncPriorityForKind('recommendation_upsert')),
    );
    expect(
      syncPriorityForKind('recommendation_upsert'),
      lessThan(syncPriorityForKind('session_start')),
    );
    expect(
      syncPriorityForKind('session_start'),
      lessThan(syncPriorityForKind('session_step_upsert')),
    );
    expect(
      syncPriorityForKind('session_step_upsert'),
      lessThan(syncPriorityForKind('session_finalize')),
    );
    expect(
      syncPriorityForKind('session_finalize'),
      lessThan(syncPriorityForKind('feedback_upsert')),
    );
  });

  test('independent leaf writes flush after the daily journey', () {
    expect(
      syncPriorityForKind('saved_routine_set'),
      greaterThan(syncPriorityForKind('feedback_upsert')),
    );
  });

  test('unknown kinds fall back to the leaf priority', () {
    expect(syncPriorityForKind('some_future_kind'), 6);
  });
}
