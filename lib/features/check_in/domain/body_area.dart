/// The closed MVP body-area vocabulary for the daily check-in.
///
/// Keys are stable taxonomy keys shared with the content catalog, so the
/// recommendation engine matches selected areas against routine body-area
/// assignments. Multiple areas may be selected in one check-in.
enum BodyArea {
  neck('neck'),
  shoulders('shoulders'),
  upperBack('upper_back'),
  lowerBack('lower_back'),
  hips('hips'),
  knees('knees'),
  fullBody('full_body');

  const BodyArea(this.key);

  final String key;
}
