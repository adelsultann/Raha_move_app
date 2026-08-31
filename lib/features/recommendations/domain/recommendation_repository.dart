/// Owns persisting a produced recommendation record locally.
///
/// Persistence is local-first and idempotent for the same [recommendationId]
/// (upsert), consistent with RAHA-025. The record is later synchronized through
/// the existing outbox/wire layer.
abstract interface class RecommendationRepository {
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
  });

  /// Marks a previously shown recommendation as rejected, recording the stable
  /// [reason] key and the rejection time for analysis. Idempotent for the same
  /// [recommendationId] (the last rejection wins).
  Future<void> reject({
    required String userId,
    required String recommendationId,
    required String reason,
    required DateTime rejectedAt,
  });
}
