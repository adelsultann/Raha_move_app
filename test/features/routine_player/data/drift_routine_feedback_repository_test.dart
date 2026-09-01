import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/routine_player/data/drift_routine_feedback_repository.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 29, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  DriftRoutineFeedbackRepository repository() =>
      DriftRoutineFeedbackRepository(database, clock: () => now);

  test(
    'save persists one response and enqueues one privacy-safe feedback_upsert',
    () async {
      final wrote = await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        rating: FeedbackRating.lessComfortable,
      );
      expect(wrote, isTrue);

      final rows = await database.select(database.localSessionFeedback).get();
      expect(rows, hasLength(1));
      expect(rows.single.sessionId, 'session-1');
      expect(rows.single.userId, 'user-1');
      expect(rows.single.rating, 'less_comfortable');

      final ops = await (database.select(
        database.syncOutbox,
      )..where((r) => r.kind.equals('feedback_upsert'))).get();
      expect(ops, hasLength(1));
      expect(ops.single.entityType, 'session_feedback');
      expect(ops.single.entityId, 'session-1');

      final payload =
          jsonDecode(ops.single.payloadJson) as Map<String, dynamic>;
      expect(payload['session_id'], 'session-1');
      expect(payload['rating'], 'less_comfortable');
      expect(payload.containsKey('created_at'), isTrue);
      // No exercise id, note, or free text in the wire payload.
      expect(payload.containsKey('uncomfortable_exercise_id'), isFalse);
      expect(payload.containsKey('note'), isFalse);
    },
  );

  test(
    're-saving the same session never overwrites or duplicates the outbox',
    () async {
      await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        rating: FeedbackRating.muchBetter,
      );
      final second = await repository().save(
        userId: 'user-1',
        sessionId: 'session-1',
        rating: FeedbackRating.same,
      );
      expect(second, isFalse);

      final rows = await database.select(database.localSessionFeedback).get();
      expect(rows, hasLength(1));
      // The first rating is retained — never overwritten by the second save.
      expect(rows.single.rating, 'much_better');

      final ops = await (database.select(
        database.syncOutbox,
      )..where((r) => r.kind.equals('feedback_upsert'))).get();
      expect(ops, hasLength(1));
    },
  );

  test('find returns the stored rating and null when absent', () async {
    await repository().save(
      userId: 'user-1',
      sessionId: 'session-1',
      rating: FeedbackRating.same,
    );

    expect(
      await repository().find(userId: 'user-1', sessionId: 'session-1'),
      FeedbackRating.same,
    );
    expect(
      await repository().find(userId: 'user-1', sessionId: 'missing'),
      isNull,
    );
    expect(
      await repository().find(userId: 'user-2', sessionId: 'session-1'),
      isNull,
    );
  });

  test('save rejects a non-completed session', () async {
    await database
        .into(database.localRoutineSessions)
        .insert(
          LocalRoutineSessionsCompanion.insert(
            id: 'in-progress',
            userId: 'user-1',
            routineId: 'routine-1',
            routineVersion: 1,
            status: 'in_progress',
            startedAt: now,
            targetDurationSeconds: 60,
            actualDurationSeconds: 0,
            totalSteps: 1,
            completionPolicyVersion: 'raha_001_v1',
            source: 'recommendation',
            localUpdatedAt: now,
          ),
        );

    await expectLater(
      repository().save(
        userId: 'user-1',
        sessionId: 'in-progress',
        rating: FeedbackRating.same,
      ),
      throwsStateError,
    );
  });
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
  await database
      .into(database.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'routine-1',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 60,
          version: 1,
          updatedAt: now,
        ),
      );
  await database
      .into(database.localRoutineSessions)
      .insert(
        LocalRoutineSessionsCompanion.insert(
          id: 'session-1',
          userId: 'user-1',
          routineId: 'routine-1',
          routineVersion: 1,
          status: 'completed',
          startedAt: now,
          completedAt: Value(now),
          targetDurationSeconds: 60,
          actualDurationSeconds: 60,
          totalSteps: 1,
          completionPolicyVersion: 'raha_001_v1',
          source: 'recommendation',
          localUpdatedAt: now,
        ),
      );
}
