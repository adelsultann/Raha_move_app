import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

/// Immutable, local-first view model for the selected local calendar week.
final class ProgressSummary {
  const ProgressSummary({
    required this.weekStart,
    required this.weeklyGoalDays,
    required this.movementDays,
    required this.verifiedActiveSeconds,
    required this.completedRoutines,
    required this.bodyAreas,
    required this.feedback,
    required this.recentHistory,
    required this.hasProvisionalProgress,
  });

  final MovementDate weekStart;
  final int weeklyGoalDays;
  final int movementDays;

  /// Credited seconds aggregated over the selected period. Display conversion is
  /// deliberately performed once after aggregation.
  final int verifiedActiveSeconds;
  final int completedRoutines;
  final List<ProgressBodyArea> bodyAreas;
  final FeedbackTrend feedback;
  final List<CompletedRoutineHistory> recentHistory;

  /// True only while a completed local session is waiting for reconciliation.
  /// Session IDs are stable, so acknowledgement replaces rather than adds data.
  final bool hasProvisionalProgress;

  bool get isEmpty => completedRoutines == 0;

  /// Whole active minutes, rounded down once for the selected-period display.
  int get verifiedActiveMinutes => verifiedActiveSeconds ~/ 60;
}

final class ProgressBodyArea {
  const ProgressBodyArea({required this.key, required this.label});
  final String key;
  final String label;
}

final class FeedbackTrend {
  const FeedbackTrend({
    required this.muchBetter,
    required this.littleBetter,
    required this.same,
    required this.lessComfortable,
  });

  final int muchBetter;
  final int littleBetter;
  final int same;
  final int lessComfortable;

  int get total => muchBetter + littleBetter + same + lessComfortable;
  int get feltBetter => muchBetter + littleBetter;
}

final class CompletedRoutineHistory {
  const CompletedRoutineHistory({
    required this.sessionId,
    required this.routineName,
    required this.completedDay,
    required this.verifiedActiveSeconds,
    required this.isProvisional,
  });

  final String sessionId;

  /// Null when the retired/missing routine has no safe localized title.
  final String? routineName;
  final MovementDate completedDay;
  final int verifiedActiveSeconds;

  int get verifiedActiveMinutes => verifiedActiveSeconds ~/ 60;
  final bool isProvisional;
}
