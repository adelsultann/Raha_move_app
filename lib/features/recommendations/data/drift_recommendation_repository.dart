import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:raha_move/core/database/app_database.dart';

import '../domain/recommendation_repository.dart';

/// Drift-backed [RecommendationRepository].
///
/// Wraps the RAHA-023 local user-data repository so a produced recommendation
/// is written in one transaction (idempotent upsert for the same id) and
/// enqueued for synchronization. Reason codes preserve the engine's canonical
/// order; the score-component breakdown is stored key-sorted so a retry is
/// byte-identical.
final class DriftRecommendationRepository implements RecommendationRepository {
  DriftRecommendationRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<void> save({
    required String userId,
    required String recommendationId,
    required String checkInId,
    required String routineId,
    required String engineVersion,
    required int rank,
    required int score,
    required List<String> reasonCodes,
    required Map<String, int> scoreComponents,
    required DateTime shownAt,
  }) {
    final now = _clock().toUtc();
    return LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveRecommendation(
      recommendation: LocalRecommendationsCompanion.insert(
        id: recommendationId,
        userId: userId,
        checkInId: checkInId,
        routineId: routineId,
        engineVersion: engineVersion,
        rank: rank,
        score: score,
        reasonCodesJson: jsonEncode(reasonCodes),
        scoreComponentsJson: Value(_encodeScoreComponents(scoreComponents)),
        shownAt: shownAt,
        localUpdatedAt: now,
      ),
    );
  }

  static String _encodeScoreComponents(Map<String, int> components) {
    final entries = components.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return jsonEncode({for (final entry in entries) entry.key: entry.value});
  }
}
