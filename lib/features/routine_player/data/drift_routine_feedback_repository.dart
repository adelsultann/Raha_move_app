import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/routine_feedback.dart';
import '../domain/routine_feedback_repository.dart';

/// Drift-backed [RoutineFeedbackRepository].
///
/// Writes delegate to the RAHA-023 local user-data repository so a feedback
/// row and its outbox operation commit in one transaction. `save` is
/// non-overwriting: an existing response is detected first and left untouched,
/// so re-submission (including a re-opened completion UI) can never change the
/// rating or enqueue a second outbox operation.
final class DriftRoutineFeedbackRepository
    implements RoutineFeedbackRepository {
  DriftRoutineFeedbackRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<bool> save({
    required String userId,
    required String sessionId,
    required FeedbackRating rating,
  }) async {
    final existing = await _findRow(userId: userId, sessionId: sessionId);
    if (existing != null) return false; // never overwrite an existing response
    final now = _clock().toUtc();
    await LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveFeedback(
      feedback: LocalSessionFeedbackCompanion.insert(
        sessionId: sessionId,
        userId: userId,
        rating: rating.key,
        createdAt: now,
        localUpdatedAt: now,
      ),
    );
    return true;
  }

  @override
  Future<FeedbackRating?> find({
    required String userId,
    required String sessionId,
  }) async {
    final row = await _findRow(userId: userId, sessionId: sessionId);
    return row == null ? null : FeedbackRating.fromKey(row.rating);
  }

  Future<LocalSessionFeedbackData?> _findRow({
    required String userId,
    required String sessionId,
  }) {
    return (_database.select(_database.localSessionFeedback)..where(
          (r) => r.sessionId.equals(sessionId) & r.userId.equals(userId),
        ))
        .getSingleOrNull();
  }
}
