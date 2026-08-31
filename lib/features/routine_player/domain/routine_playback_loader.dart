import 'playback_plan.dart';

/// Thrown when a routine cannot be loaded for playback: it does not exist, is
/// not published, or its required media cannot be resolved to one delivery per
/// schedulable step. The player fails closed rather than start a broken session.
final class RoutinePlaybackUnavailableException implements Exception {
  const RoutinePlaybackUnavailableException();
}

/// Loads a localized, ordered [RoutinePlaybackPlan] from the local content
/// cache, independent of any network or media SDK.
abstract interface class RoutinePlaybackLoader {
  Future<RoutinePlaybackPlan> load(String routineId, String locale);
}
