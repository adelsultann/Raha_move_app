import 'check_in_answers.dart';

/// Owns persisting a completed daily check-in.
///
/// Persistence is local-first and atomic (one Drift transaction); the check-in
/// row is keyed by [CheckInRepository.save]'s [checkInId], so re-saving the same
/// id updates in place rather than creating a duplicate. Synchronization is a
/// separate concern owned by the existing outbox/wire layer.
abstract interface class CheckInRepository {
  /// Persists one complete check-in for [userId] with the given stable
  /// [checkInId] and [startedAt]. Idempotent for the same [checkInId].
  Future<void> save({
    required String userId,
    required String checkInId,
    required DateTime startedAt,
    required CheckInAnswers answers,
  });

  /// Reads the persisted answers for [checkInId] owned by [userId], or null when
  /// the check-in is missing or belongs to another user. Used by the
  /// recommendation flow to rebuild inputs after a route restore without
  /// relying on transient in-memory state, and to keep one user's answers from
  /// surfacing for another (RAHA-030).
  Future<CheckInAnswers?> read(String userId, String checkInId);
}
