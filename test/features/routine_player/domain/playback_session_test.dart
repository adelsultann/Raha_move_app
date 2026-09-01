import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/routine_player/domain/playback_session.dart';

void main() {
  group('verifiedActiveMinutes', () {
    RoutinePlaybackSession session(int creditedSeconds) =>
        RoutinePlaybackSession(
          sessionId: 's',
          routineId: 'r',
          routineVersion: 1,
          routineName: 'Routine',
          status: PlaybackStatus.completed,
          currentStepIndex: 0,
          steps: [
            RoutineStepPlayback(
              stepId: 'step-1',
              exerciseId: 'ex-1',
              name: 'Step',
              durationSeconds: creditedSeconds,
              state: StepPlaybackState.completed,
              creditedSeconds: creditedSeconds,
              skipRequested: false,
            ),
          ],
        );

    test('floors credited active seconds to whole minutes', () {
      expect(session(420).verifiedActiveMinutes, 7);
      expect(session(336).verifiedActiveMinutes, 5);
      expect(session(60).verifiedActiveMinutes, 1);
      expect(session(59).verifiedActiveMinutes, 0);
    });

    test('reflects credited time only, never the scheduled target', () {
      // A partial 70-second step credited 61 seconds is one verified minute.
      final partial = RoutinePlaybackSession(
        sessionId: 's',
        routineId: 'r',
        routineVersion: 1,
        routineName: 'Routine',
        status: PlaybackStatus.completed,
        currentStepIndex: 0,
        steps: [
          RoutineStepPlayback(
            stepId: 'step-1',
            exerciseId: 'ex-1',
            name: 'Step',
            durationSeconds: 70,
            state: StepPlaybackState.partial,
            creditedSeconds: 61,
            skipRequested: true,
          ),
        ],
      );
      expect(partial.totalDurationSeconds, 70);
      expect(partial.verifiedActiveMinutes, 1);
    });
  });
}
