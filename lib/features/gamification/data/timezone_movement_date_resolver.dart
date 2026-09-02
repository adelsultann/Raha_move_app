import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/weekly_goal_progress.dart';

/// Converts UTC instants using the IANA timezone saved with the profile/session.
/// The timezone database is initialized lazily to keep startup ownership with
/// the existing bootstrap while remaining safe for isolated repository tests.
final class TimezoneMovementDateResolver {
  MovementDate resolve(DateTime instant, String ianaTimezone) {
    _ensureInitialized();
    try {
      final local = tz.TZDateTime.from(
        instant.toUtc(),
        tz.getLocation(ianaTimezone),
      );
      return MovementDate(local.year, local.month, local.day);
    } on ArgumentError {
      throw ArgumentError.value(
        ianaTimezone,
        'ianaTimezone',
        'A supported IANA timezone is required for movement-day projection.',
      );
    }
  }

  static var _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }
}
