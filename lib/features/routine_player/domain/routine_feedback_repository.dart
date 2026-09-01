import 'routine_feedback.dart';

/// App-owned boundary for persisting a single post-routine feedback response
/// locally before synchronization (RAHA-053).
///
/// Writes are committed atomically with their synchronization outbox operation
/// by the data layer, so a response is never lost between being saved and being
/// queued for upload.
abstract interface class RoutineFeedbackRepository {
  /// Creates the first response for [sessionId]. Returns true when a new
  /// response was written (atomically with its outbox operation); returns false
  /// without writing or re-enqueuing when a response already exists, so an
  /// existing response is never overwritten.
  Future<bool> save({
    required String userId,
    required String sessionId,
    required FeedbackRating rating,
  });

  /// The existing response for [sessionId], or null when none.
  Future<FeedbackRating?> find({
    required String userId,
    required String sessionId,
  });
}
