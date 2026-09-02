import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

void main() {
  test('weeks begin on Monday and end on Sunday', () {
    expect(
      const MovementDate(2026, 9, 6).monday,
      const MovementDate(2026, 8, 31),
    );
    expect(
      const MovementDate(2026, 9, 7).monday,
      const MovementDate(2026, 9, 7),
    );
  });

  test('weekly goal accepts only the approved one through seven range', () {
    expect(validatedWeeklyGoalDays(1), 1);
    expect(validatedWeeklyGoalDays(7), 7);
    expect(() => validatedWeeklyGoalDays(0), throwsArgumentError);
    expect(() => validatedWeeklyGoalDays(8), throwsArgumentError);
    expect(GamificationRules.defaultWeeklyGoalDays, 3);
    expect(GamificationRules.pointsCompletionV1, 'points_completion_v1');
    expect(GamificationRules.movementDayV1, 'movement_day_v1');
    expect(GamificationRules.completionPoints, 10);
  });
}
