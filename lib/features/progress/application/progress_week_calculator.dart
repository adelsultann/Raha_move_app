import 'package:raha_move/features/gamification/data/timezone_movement_date_resolver.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

/// Pure current-period rule. The provider supplies the injected clock and
/// re-runs this whenever the persisted profile timezone changes.
final class ProgressWeekCalculator {
  ProgressWeekCalculator({TimezoneMovementDateResolver? dateResolver})
    : _dateResolver = dateResolver ?? TimezoneMovementDateResolver();

  final TimezoneMovementDateResolver _dateResolver;

  MovementDate currentWeek({required DateTime now, required String timezone}) =>
      _dateResolver.resolve(now.toUtc(), timezone).monday;
}
