/// Dependency-ordered flush priority for the user-data push queue, keyed by the
/// RAHA-025 wire operation kind. Lower values flush earlier.
///
/// The ordering mirrors the trusted backend contract so a parent is accepted
/// before its children are pushed:
///
/// ```text
/// check_in_upsert
///   -> recommendation_upsert
///   -> session_start -> session_step_upsert(s) -> session_finalize
///   -> feedback_upsert
///   -> saved_routine_set
/// ```
///
/// Session steps share one rank and are further ordered by their `sequence`
/// (`position_snapshot`) inside the engine. Saved routines have no dependency
/// on the daily journey and flush last; the engine breaks remaining ties
/// deterministically by sequence, creation time, and outbox id.
const Map<String, int> syncKindPriority = <String, int>{
  'check_in_upsert': 0,
  'recommendation_upsert': 1,
  'session_start': 2,
  'session_step_upsert': 3,
  'session_finalize': 4,
  'feedback_upsert': 5,
  'saved_routine_set': 6,
};

/// Priority rank for a wire operation [kind]. Unknown kinds are treated as
/// independent leaf writes so a future additive operation never blocks the
/// queue.
int syncPriorityForKind(String kind) => syncKindPriority[kind] ?? 6;
