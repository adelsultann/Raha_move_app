/// A user-owned saved routine projection. It contains only Raha-owned routine
/// identity and localized catalog content; provider provenance never reaches it.
final class SavedRoutine {
  const SavedRoutine({
    required this.routineId,
    required this.title,
    required this.isPlayable,
  });

  final String routineId;
  final String title;
  final bool isPlayable;
}
