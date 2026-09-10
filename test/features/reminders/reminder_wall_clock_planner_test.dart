import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';
import 'package:raha_move/features/reminders/domain/reminder_wall_clock_planner.dart';

void main() {
  test('keeps the 18:00 local wall clock through a DST boundary', () {
    final schedule = ReminderSchedule.dailyAtSix(
      id: 'id',
      userId: 'user',
      timezone: 'America/New_York',
    );
    final planner = ReminderWallClockPlanner();
    expect(
      planner.nextLocalOccurrence(schedule, DateTime(2026, 3, 8, 17, 59)),
      DateTime(2026, 3, 8, 18),
    );
    expect(
      planner.nextLocalOccurrence(schedule, DateTime(2026, 11, 1, 18, 1)),
      DateTime(2026, 11, 2, 18),
    );
  });
}
