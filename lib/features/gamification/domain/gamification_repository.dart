import 'weekly_goal_progress.dart';

/// Read boundary for the local, reconcilable RAHA-070 progress projection.
/// Implementations may use Drift, but consumers and rules remain infrastructure
/// independent.
abstract interface class GamificationRepository {
  Future<WeeklyGoalProgress> currentWeeklyGoal({String? userId});
}
