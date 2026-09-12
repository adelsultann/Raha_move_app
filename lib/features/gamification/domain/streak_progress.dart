import 'weekly_goal_progress.dart';

/// Immutable server or local estimate of the versioned streak state.
final class StreakProgress {
  const StreakProgress({
    required this.currentDays,
    required this.longestDays,
    required this.ruleVersion,
    required this.isAuthoritative,
  }) : assert(currentDays >= 0),
       assert(longestDays >= currentDays);

  final int currentDays;
  final int longestDays;
  final String ruleVersion;
  final bool isAuthoritative;
}

/// Pure `streak_v1` calculation for controlled local estimates and tests.
/// Authoritative server results always replace this value after synchronization.
StreakProgress calculateStreakV1({
  required Iterable<MovementDate> movementDates,
  required MovementDate today,
  bool isAuthoritative = false,
}) {
  final dates = movementDates.toSet().toList()..sort();
  if (dates.isEmpty) {
    return StreakProgress(
      currentDays: 0,
      longestDays: 0,
      ruleVersion: GamificationRules.streakV1,
      isAuthoritative: isAuthoritative,
    );
  }
  var longest = 1;
  var run = 1;
  for (var index = 1; index < dates.length; index++) {
    if (dates[index - 1].addDays(1) == dates[index]) {
      run++;
      if (run > longest) longest = run;
    } else {
      run = 1;
    }
  }
  final latest = dates.last;
  var current = 0;
  if (latest == today || latest == today.addDays(-1)) {
    current = 1;
    for (var index = dates.length - 2; index >= 0; index--) {
      if (dates[index].addDays(1) != dates[index + 1]) break;
      current++;
    }
  }
  return StreakProgress(
    currentDays: current,
    longestDays: longest,
    ruleVersion: GamificationRules.streakV1,
    isAuthoritative: isAuthoritative,
  );
}
