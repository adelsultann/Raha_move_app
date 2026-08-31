/// The closed MVP desired-outcome (goal) vocabulary for the daily check-in.
///
/// Keys are stable taxonomy keys shared with the content catalog, so RAHA-041's
/// recommendation engine matches them against routine goal assignments.
enum CheckInGoal {
  easeStiffness('ease_stiffness'),
  moveMoreFreely('move_more_freely'),
  feelEnergized('feel_energized'),
  relax('relax'),
  deskBreak('desk_break');

  const CheckInGoal(this.key);

  final String key;
}
