/// A localized, completed routine available from the user's local history.
///
/// This is intentionally a small immutable read model: Today must not expose
/// database rows or provider metadata to its presentation layer.
final class TodayCompletedRoutine {
  const TodayCompletedRoutine({
    required this.routineId,
    required this.sessionId,
    required this.name,
    required this.completedAt,
  });

  final String routineId;
  final String sessionId;
  final String name;
  final DateTime completedAt;
}

/// An in-progress routine rendered by Today. The session identifier remains
/// separate from the routine identity so resume navigation survives restart.
final class TodayResumableRoutine {
  const TodayResumableRoutine({
    required this.routineId,
    required this.sessionId,
    required this.name,
  });

  final String routineId;
  final String sessionId;

  /// Null only when locally cached historical content has no supported
  /// translation. Presentation uses a localized generic fallback in that case.
  final String? name;
}

/// App-owned local-history boundary for Today.
abstract interface class TodayRepository {
  Future<TodayCompletedRoutine?> latestCompletedRoutine({
    required String userId,
    required String locale,
  });

  /// Resolves requested locale first, then English as the approved content
  /// fallback. It intentionally never returns provider text.
  Future<String?> routineName({
    required String routineId,
    required String locale,
  });

  /// Emits after any local session, progress projection, or profile write that
  /// can alter Today. This keeps an already-mounted Today route current while
  /// offline local writes are committed.
  Stream<void> watchChanges({required String userId});
}
