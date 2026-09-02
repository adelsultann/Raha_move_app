/// The immutable, language-neutral RAHA-070 rules. Server results remain the
/// authority; these constants describe only the local projection contract.
abstract final class GamificationRules {
  static const String pointsCompletionV1 = 'points_completion_v1';
  static const String movementDayV1 = 'movement_day_v1';
  static const int completionPoints = 10;
  static const int defaultWeeklyGoalDays = 3;
  static const int minWeeklyGoalDays = 1;
  static const int maxWeeklyGoalDays = 7;
}

/// A calendar date without a time or timezone. It is deliberately not a
/// [DateTime] so movement-day comparisons cannot accidentally use device time.
final class MovementDate implements Comparable<MovementDate> {
  const MovementDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Monday is day 1 and Sunday is day 7, matching the approved policy.
  int get weekday => DateTime.utc(year, month, day).weekday;

  MovementDate get monday => addDays(1 - weekday);

  MovementDate addDays(int days) {
    final value = DateTime.utc(year, month, day).add(Duration(days: days));
    return MovementDate(value.year, value.month, value.day);
  }

  @override
  int compareTo(MovementDate other) => DateTime.utc(
    year,
    month,
    day,
  ).compareTo(DateTime.utc(other.year, other.month, other.day));

  @override
  bool operator ==(Object other) =>
      other is MovementDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Validates the user-selected weekly target at the domain boundary.
int validatedWeeklyGoalDays(int value) {
  if (value < GamificationRules.minWeeklyGoalDays ||
      value > GamificationRules.maxWeeklyGoalDays) {
    throw ArgumentError.value(
      value,
      'value',
      'Weekly movement goal must be between 1 and 7 days.',
    );
  }
  return value;
}

/// A current-week, read-only view. [isAuthoritative] is false only while it is
/// computed from locally completed sessions awaiting server reconciliation.
final class WeeklyGoalProgress {
  const WeeklyGoalProgress({
    required this.weekStart,
    required this.goalDays,
    required this.movementDays,
    required this.pendingPointAwards,
    required this.isAuthoritative,
    this.confirmedPoints,
  }) : assert(goalDays >= GamificationRules.minWeeklyGoalDays),
       assert(goalDays <= GamificationRules.maxWeeklyGoalDays),
       assert(movementDays >= 0),
       assert(pendingPointAwards >= 0);

  final MovementDate weekStart;
  final int goalDays;
  final int movementDays;
  final int pendingPointAwards;
  final bool isAuthoritative;
  final int? confirmedPoints;

  int get boundedMovementDays => movementDays.clamp(0, goalDays).toInt();
  bool get goalReached => movementDays >= goalDays;
  bool get hasPendingConfirmation => pendingPointAwards > 0;
}
