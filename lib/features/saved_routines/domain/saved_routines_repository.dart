import 'saved_routine.dart';

/// Local-first contract for the user's saved routine collection.
abstract interface class SavedRoutinesRepository {
  Future<bool> isSaved({required String userId, required String routineId});

  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  });

  /// Saves only a currently published free routine and atomically queues its
  /// durable sync operation.
  Future<void> save({required String userId, required String routineId});

  /// Retains a tombstone locally so a later pull cannot resurrect this save.
  Future<void> unsave({required String userId, required String routineId});
}
