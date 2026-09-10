import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/reminders/data/flutter_local_reminder_platform.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final schedule = ReminderSchedule.dailyAtSix(
    id: 'reminder-user',
    userId: 'user',
    timezone: 'America/New_York',
  );
  test('actual adapter calendar preserves 18:00 after spring forward', () {
    final location = tz.getLocation('America/New_York');
    final now = tz.TZDateTime(location, 2026, 3, 8, 18, 1);
    final candidate = ReminderSchedulingCalendar.nextOccurrence(
      schedule: schedule,
      weekday: DateTime.monday,
      now: now,
      location: location,
    );
    expect(candidate, tz.TZDateTime(location, 2026, 3, 9, 18));
    expect([candidate.hour, candidate.minute], [18, 0]);
  });
  test('actual adapter calendar preserves 18:00 after fall back', () {
    final location = tz.getLocation('America/New_York');
    final now = tz.TZDateTime(location, 2026, 11, 1, 18, 1);
    final candidate = ReminderSchedulingCalendar.nextOccurrence(
      schedule: schedule,
      weekday: DateTime.monday,
      now: now,
      location: location,
    );
    expect(candidate, tz.TZDateTime(location, 2026, 11, 2, 18));
    expect([candidate.hour, candidate.minute], [18, 0]);
  });
  test('notification identity is stable across reconstructed adapters', () {
    expect(
      FlutterLocalReminderPlatform.notificationId('reminder-user', 1),
      FlutterLocalReminderPlatform.notificationId('reminder-user', 1),
    );
    expect(
      FlutterLocalReminderPlatform.notificationId('reminder-user', 1),
      isNot(FlutterLocalReminderPlatform.notificationId('unrelated', 1)),
    );
  });
}
