import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/gamification/domain/streak_progress.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

void main() {
  test('first completion starts a one-day streak', () {
    final progress = calculateStreakV1(
      movementDates: const [MovementDate(2026, 9, 10)],
      today: const MovementDate(2026, 9, 10),
    );
    expect(progress.currentDays, 1);
    expect(progress.longestDays, 1);
    expect(progress.ruleVersion, GamificationRules.streakV1);
  });

  test('counts consecutive unique movement days and preserves longest run', () {
    final progress = calculateStreakV1(
      movementDates: const [
        MovementDate(2026, 9, 5),
        MovementDate(2026, 9, 6),
        MovementDate(2026, 9, 6),
        MovementDate(2026, 9, 7),
      ],
      today: const MovementDate(2026, 9, 7),
    );
    expect(progress.currentDays, 3);
    expect(progress.longestDays, 3);
  });

  test(
    'a gap resets the active streak without erasing consistency history',
    () {
      final progress = calculateStreakV1(
        movementDates: const [
          MovementDate(2026, 9, 1),
          MovementDate(2026, 9, 2),
          MovementDate(2026, 9, 4),
        ],
        today: const MovementDate(2026, 9, 4),
      );
      expect(progress.currentDays, 1);
      expect(progress.longestDays, 2);
    },
  );

  test('a stale latest day has no active streak', () {
    final progress = calculateStreakV1(
      movementDates: const [MovementDate(2026, 9, 1)],
      today: const MovementDate(2026, 9, 4),
    );
    expect(progress.currentDays, 0);
    expect(progress.longestDays, 1);
  });
}
