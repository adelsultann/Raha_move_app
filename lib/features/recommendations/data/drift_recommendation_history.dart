import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/recommendation_history.dart';

/// Loads the recommendation history inputs (recent completed routines and
/// previously uncomfortable exercises) from the local Drift cache.
final class DriftRecommendationHistory {
  DriftRecommendationHistory(this._database);

  final AppDatabase _database;

  Future<RecommendationHistory> loadFor(String userId) async {
    final sessions =
        await (_database.select(_database.localRoutineSessions)..where(
              (r) => r.userId.equals(userId) & r.status.equals('completed'),
            ))
            .get();

    final recentAttempts = <RecentRoutineAttempt>[
      for (final session in sessions)
        if (session.completedAt != null)
          RecentRoutineAttempt(
            routineId: session.routineId,
            completedAt: session.completedAt!.toUtc(),
          ),
    ];

    final routineBySession = {
      for (final session in sessions) session.id: session.routineId,
    };

    final feedback =
        await (_database.select(_database.localSessionFeedback)..where(
              (r) =>
                  r.userId.equals(userId) & r.rating.equals('less_comfortable'),
            ))
            .get();

    final uncomfortableExerciseIds = <String>{
      for (final row in feedback)
        if (row.uncomfortableExerciseId != null) row.uncomfortableExerciseId!,
    };

    // Aggregate categorical less-comfortable signal: the routine behind each
    // less-comfortable response, resolved through the owning session.
    final lessComfortableRoutineIds = <String>{
      for (final row in feedback)
        if (routineBySession[row.sessionId] != null)
          routineBySession[row.sessionId]!,
    };

    return RecommendationHistory(
      recentAttempts: List.unmodifiable(recentAttempts),
      uncomfortableExerciseIds: uncomfortableExerciseIds,
      lessComfortableRoutineIds: lessComfortableRoutineIds,
    );
  }
}
