import 'weekly_goal_progress.dart';
import 'streak_progress.dart';
import 'achievement_progress.dart';

/// Read boundary for the local, reconcilable RAHA-070 progress projection.
/// Implementations may use Drift, but consumers and rules remain infrastructure
/// independent.
abstract interface class GamificationRepository {
  Future<WeeklyGoalProgress> currentWeeklyGoal({String? userId});

  Future<StreakProgress> currentStreak({String? userId});

  /// Server-owned achievement catalog and awards cached for offline reading.
  Future<List<AchievementProgress>> achievements({String? userId});
}
