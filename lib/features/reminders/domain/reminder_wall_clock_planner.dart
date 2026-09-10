import 'reminder_schedule.dart';

/// Pure wall-clock planning used to prove that a schedule is not converted to
/// a fixed UTC instant. Native adapters map this plan to IANA timezone rules.
final class ReminderWallClockPlanner {
  const ReminderWallClockPlanner();

  DateTime nextLocalOccurrence(ReminderSchedule schedule, DateTime localNow) {
    for (var offset = 0; offset <= 7; offset++) {
      final day = DateTime(
        localNow.year,
        localNow.month,
        localNow.day + offset,
      );
      if (!schedule.daysOfWeek.contains(day.weekday)) continue;
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        schedule.hour,
        schedule.minute,
      );
      if (candidate.isAfter(localNow)) return candidate;
    }
    throw StateError('A recurring reminder needs at least one day.');
  }
}
