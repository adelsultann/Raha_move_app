import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/playback_session.dart';
import '../domain/routine_session_repository.dart';

part 'routine_player_state.freezed.dart';

/// The player's screen state. Loading/failed mirror the plan (or restore) load;
/// ready carries the in-memory [RoutinePlaybackSession] the controller mutates;
/// conflict is shown when an ordinary new start would collide with an existing
/// in-progress session and the user must resume or abandon it.
@freezed
sealed class RoutinePlayerState with _$RoutinePlayerState {
  const factory RoutinePlayerState.loading() = RoutinePlayerLoading;

  const factory RoutinePlayerState.failed() = RoutinePlayerFailed;

  const factory RoutinePlayerState.ready({
    required RoutinePlaybackSession session,
  }) = RoutinePlayerReady;

  const factory RoutinePlayerState.conflict({
    required RoutineSessionSnapshot resumable,
  }) = RoutinePlayerConflict;

  const factory RoutinePlayerState.saveError() = RoutinePlayerSaveError;
}
