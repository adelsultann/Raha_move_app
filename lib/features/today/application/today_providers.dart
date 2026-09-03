import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/gamification/application/gamification_providers.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_today_repository.dart';
import '../domain/today_repository.dart';

part 'today_providers.g.dart';

@riverpod
TodayRepository todayRepository(Ref ref) =>
    DriftTodayRepository(ref.watch(appDatabaseProvider));

/// All data required by Today is local-first. The progress projection retains
/// whether its values are confirmed, rather than requiring a connectivity SDK.
final class TodayDashboard {
  const TodayDashboard({
    required this.weeklyGoal,
    required this.resumableRoutine,
    required this.latestCompletedRoutine,
  });

  final WeeklyGoalProgress weeklyGoal;
  final TodayResumableRoutine? resumableRoutine;
  final TodayCompletedRoutine? latestCompletedRoutine;
}

@riverpod
Stream<TodayDashboard> todayDashboard(Ref ref) async* {
  final auth = await ref.watch(authControllerProvider.future);
  final userId = auth.activeUserId;
  if (userId == null) throw StateError('Today requires an active user');
  final locale = await ref.watch(localeControllerProvider.future);

  final repository = ref.watch(todayRepositoryProvider);

  Future<TodayDashboard> load() async {
    ref.invalidate(weeklyGoalProgressProvider);
    ref.invalidate(resumableRoutineSessionProvider);
    final values = await Future.wait<Object?>([
      ref.read(weeklyGoalProgressProvider.future),
      ref.read(resumableRoutineSessionProvider.future),
      repository.latestCompletedRoutine(
        userId: userId,
        locale: locale.languageCode,
      ),
    ]);
    final session = values[1] as RoutineSessionSnapshot?;
    final name = session == null
        ? null
        : await repository.routineName(
            routineId: session.routineId,
            locale: locale.languageCode,
          );
    return TodayDashboard(
      weeklyGoal: values[0]! as WeeklyGoalProgress,
      resumableRoutine: session == null
          ? null
          : TodayResumableRoutine(
              routineId: session.routineId,
              sessionId: session.sessionId,
              name: name,
            ),
      latestCompletedRoutine: values[2] as TodayCompletedRoutine?,
    );
  }

  yield await load();
  await for (final _ in repository.watchChanges(userId: userId)) {
    yield await load();
  }
}
