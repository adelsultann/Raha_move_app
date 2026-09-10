/// A device-local recurring reminder. Weekdays use ISO values 1 (Monday)–7.
final class ReminderSchedule {
  const ReminderSchedule({
    required this.id,
    required this.userId,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    required this.timezone,
    required this.enabled,
  });

  factory ReminderSchedule.dailyAtSix({
    required String id,
    required String userId,
    required String timezone,
  }) => ReminderSchedule(
    id: id,
    userId: userId,
    hour: 18,
    minute: 0,
    daysOfWeek: const {1, 2, 3, 4, 5, 6, 7},
    timezone: timezone,
    enabled: true,
  );

  final String id;
  final String userId;
  final int hour;
  final int minute;
  final Set<int> daysOfWeek;
  final String timezone;
  final bool enabled;

  ReminderSchedule copyWith({
    int? hour,
    int? minute,
    Set<int>? daysOfWeek,
    String? timezone,
    bool? enabled,
  }) => ReminderSchedule(
    id: id,
    userId: userId,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    timezone: timezone ?? this.timezone,
    enabled: enabled ?? this.enabled,
  );
}

/// Notification text is deliberately static and contains no personal or health
/// data, identifiers, links, or payload fields.
final class ReminderNotificationContent {
  const ReminderNotificationContent({required this.title, required this.body});
  final String title;
  final String body;
}

enum ReminderPermission { notDetermined, granted, denied }
