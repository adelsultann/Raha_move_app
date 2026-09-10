import 'reminder_schedule.dart';

abstract interface class ReminderRepository {
  Future<ReminderSchedule?> read(String userId);
  Future<void> save(ReminderSchedule schedule);
  Future<void> remove(String userId);
}

abstract interface class ReminderPermissionStore {
  Future<bool> wasDenied(String userId);
  Future<void> recordDenied(String userId);
  Future<void> clearDenied(String userId);
}

abstract interface class ReminderPlatform {
  Future<String> currentIanaTimezone();
  Future<ReminderPermission> permissionStatus();
  Future<bool> requestPermission();
  Future<void> schedule(
    ReminderSchedule schedule,
    ReminderNotificationContent content,
  );
  Future<void> cancel(String scheduleId);
  Future<void> openSettings();
}
