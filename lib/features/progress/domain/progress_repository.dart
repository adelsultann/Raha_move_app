import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import 'progress_summary.dart';

abstract interface class ProgressRepository {
  Stream<ProgressSummary> watchWeeklySummary({
    required MovementDate weekStart,
    required String locale,
  });
}
