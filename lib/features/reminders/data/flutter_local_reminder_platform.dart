import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_repository.dart';
import '../domain/reminder_schedule.dart';

/// The only adapter that knows about the native notifications plugin.
final class FlutterLocalReminderPlatform implements ReminderPlatform {
  FlutterLocalReminderPlatform({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  static const _systemChannel = MethodChannel('raha/reminders/system');
  var _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  @override
  Future<String> currentIanaTimezone() async {
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    return zone.identifier;
  }

  @override
  Future<ReminderPermission> permissionStatus() async {
    await _initialize();
    final status = await _systemChannel.invokeMethod<String>(
      'permissionStatus',
    );
    return switch (status) {
      'granted' => ReminderPermission.granted,
      'denied' => ReminderPermission.denied,
      _ => ReminderPermission.notDetermined,
    };
  }

  @override
  Future<bool> requestPermission() async {
    await _initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: false,
          sound: false,
        ) ??
        false;
  }

  @override
  Future<void> schedule(
    ReminderSchedule schedule,
    ReminderNotificationContent content,
  ) async {
    await _initialize();
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(schedule.timezone));
    await cancel(schedule.id);
    for (final day in schedule.daysOfWeek) {
      await _plugin.zonedSchedule(
        _notificationId(schedule.id, day),
        content.title,
        content.body,
        ReminderSchedulingCalendar.nextOccurrence(
          schedule: schedule,
          weekday: day,
          now: tz.TZDateTime.now(tz.local),
          location: tz.local,
        ),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'gentle_reminders',
            content.title,
            channelDescription: content.body,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Stable FNV-1a identity, independent of Dart's randomized String.hashCode.
  static int notificationId(String scheduleId, int weekday) {
    var hash = 0x811c9dc5;
    for (final unit in '$scheduleId:$weekday'.codeUnits) {
      hash = (hash ^ unit) * 0x01000193;
      hash &= 0x7fffffff;
    }
    return hash;
  }

  int _notificationId(String scheduleId, int weekday) =>
      notificationId(scheduleId, weekday);

  @override
  Future<void> cancel(String scheduleId) async {
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(_notificationId(scheduleId, day));
    }
  }

  @override
  Future<void> openSettings() =>
      _systemChannel.invokeMethod<void>('openNotificationSettings');
}

/// The exact calendar candidate logic used by the native scheduling adapter.
final class ReminderSchedulingCalendar {
  static tz.TZDateTime nextOccurrence({
    required ReminderSchedule schedule,
    required int weekday,
    required tz.TZDateTime now,
    required tz.Location location,
  }) {
    var candidate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      schedule.hour,
      schedule.minute,
    );
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      final nextDate = DateTime(
        candidate.year,
        candidate.month,
        candidate.day + 1,
      );
      candidate = tz.TZDateTime(
        location,
        nextDate.year,
        nextDate.month,
        nextDate.day,
        schedule.hour,
        schedule.minute,
      );
    }
    return candidate;
  }
}
