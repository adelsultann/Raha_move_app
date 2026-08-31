import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/playback_session.dart';

part 'routine_player_state.freezed.dart';

/// The player's screen state. Loading/failed mirror the plan load; ready carries
/// the in-memory [RoutinePlaybackSession] the controller mutates.
@freezed
sealed class RoutinePlayerState with _$RoutinePlayerState {
  const factory RoutinePlayerState.loading() = RoutinePlayerLoading;

  const factory RoutinePlayerState.failed() = RoutinePlayerFailed;

  const factory RoutinePlayerState.ready({
    required RoutinePlaybackSession session,
  }) = RoutinePlayerReady;
}
