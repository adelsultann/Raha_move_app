import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/recommendations/data/drift_recommendation_repository.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  test(
    'persists engine version, score, reason codes and score components',
    () async {
      final repository = DriftRecommendationRepository(
        database,
        clock: () => now,
      );

      await repository.save(
        userId: 'user-1',
        recommendationId: 'rec-1',
        checkInId: 'check-in-1',
        routineId: 'raha_rt_000001',
        engineVersion: 'rules_v1',
        rank: 0,
        score: 150,
        reasonCodes: const ['body_area_match', 'goal_match'],
        scoreComponents: const {'body_area_match': 80, 'goal_match': 25},
        shownAt: now,
      );

      final row = await (database.select(
        database.localRecommendations,
      )..where((r) => r.id.equals('rec-1'))).getSingle();

      expect(row.userId, 'user-1');
      expect(row.checkInId, 'check-in-1');
      expect(row.routineId, 'raha_rt_000001');
      expect(row.engineVersion, 'rules_v1');
      expect(row.rank, 0);
      expect(row.score, 150);
      expect(jsonDecode(row.reasonCodesJson), [
        'body_area_match',
        'goal_match',
      ]);
      expect(jsonDecode(row.scoreComponentsJson), {
        'body_area_match': 80,
        'goal_match': 25,
      });
      expect(row.shownAt.toUtc(), now);
    },
  );

  test('re-saving the same id updates in place without duplicating', () async {
    final repository = DriftRecommendationRepository(
      database,
      clock: () => now,
    );

    Future<void> save(String id, int score) => repository.save(
      userId: 'user-1',
      recommendationId: id,
      checkInId: 'check-in-1',
      routineId: 'raha_rt_000001',
      engineVersion: 'rules_v1',
      rank: 0,
      score: score,
      reasonCodes: const ['goal_match'],
      scoreComponents: const {'goal_match': 25},
      shownAt: now,
    );

    await save('rec-1', 150);
    await save('rec-1', 175);

    final rows = await (database.select(
      database.localRecommendations,
    )..where((r) => r.id.equals('rec-1'))).get();
    expect(rows, hasLength(1));
    expect(rows.single.score, 175);
  });

  test('reject records the reason and rejection time', () async {
    final repository = DriftRecommendationRepository(
      database,
      clock: () => now,
    );
    await repository.save(
      userId: 'user-1',
      recommendationId: 'rec-1',
      checkInId: 'check-in-1',
      routineId: 'raha_rt_000001',
      engineVersion: 'rules_v1',
      rank: 0,
      score: 150,
      reasonCodes: const ['goal_match'],
      scoreComponents: const {'goal_match': 25},
      shownAt: now,
    );

    final rejectedAt = now.add(const Duration(minutes: 1));
    await repository.reject(
      userId: 'user-1',
      recommendationId: 'rec-1',
      reason: 'too_easy',
      rejectedAt: rejectedAt,
    );

    final row = await (database.select(
      database.localRecommendations,
    )..where((r) => r.id.equals('rec-1'))).getSingle();
    expect(row.rejectionReason, 'too_easy');
    expect(row.rejectedAt!.toUtc(), rejectedAt.toUtc());
  });

  test('rejecting another user\'s recommendation is rejected', () async {
    final repository = DriftRecommendationRepository(
      database,
      clock: () => now,
    );
    await repository.save(
      userId: 'user-1',
      recommendationId: 'rec-1',
      checkInId: 'check-in-1',
      routineId: 'raha_rt_000001',
      engineVersion: 'rules_v1',
      rank: 0,
      score: 150,
      reasonCodes: const ['goal_match'],
      scoreComponents: const {'goal_match': 25},
      shownAt: now,
    );

    await expectLater(
      repository.reject(
        userId: 'user-2',
        recommendationId: 'rec-1',
        reason: 'other',
        rejectedAt: now,
      ),
      throwsA(isA<StateError>()),
    );
  });
}

Future<void> _seed(AppDatabase db, DateTime now) async {
  for (final (key, kind) in const [
    ('ease_stiffness', 'goal'),
    ('seated', 'position'),
  ]) {
    await db
        .into(db.localTaxonomies)
        .insert(LocalTaxonomiesCompanion.insert(key: key, kind: kind));
  }

  await db
      .into(db.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );

  await db
      .into(db.localRoutines)
      .insert(
        LocalRoutinesCompanion.insert(
          id: 'raha_rt_000001',
          status: 'published',
          accessTier: 'free',
          difficulty: 'beginner',
          estimatedDurationSeconds: 300,
          version: 1,
          updatedAt: now,
        ),
      );

  await db
      .into(db.localCheckIns)
      .insert(
        LocalCheckInsCompanion.insert(
          id: 'check-in-1',
          userId: 'user-1',
          bodyState: 'stiff',
          goalKey: 'ease_stiffness',
          availableMinutes: 5,
          positionKey: const Value('seated'),
          startedAt: now.subtract(const Duration(minutes: 1)),
          completedAt: Value(now),
          localUpdatedAt: now,
        ),
      );

  // Resolve the stable routine public id to a backend UUID so the outbox write
  // completes cleanly instead of parking as an unmapped id.
  await db
      .into(db.localIdMappings)
      .insert(
        LocalIdMappingsCompanion.insert(
          kind: RemoteIdMappingKind.routine,
          localId: 'raha_rt_000001',
          remoteId: '03000000-0000-0000-0000-000000000001',
        ),
      );
}
