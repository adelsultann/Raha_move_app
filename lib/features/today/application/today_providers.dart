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
  if (!ref.mounted) return;
  final userId = auth.activeUserId;
  if (userId == null) throw StateError('Today requires an active user');
  final locale = await ref.watch(localeControllerProvider.future);
  if (!ref.mounted) return;

  final repository = ref.watch(todayRepositoryProvider);
  final gamificationRepository = ref.watch(gamificationRepositoryProvider);
  final sessionRepository = ref.watch(routineSessionRepositoryProvider);

  Future<TodayDashboard?> load() async {
    if (!ref.mounted) return null;
    Future<RoutineSessionSnapshot?> loadResumableSession() async {
      await sessionRepository.expireInactiveSessions(userId: userId);
      return sessionRepository.resumable(userId: userId);
    }

    final values = await Future.wait<Object?>([
      gamificationRepository.currentWeeklyGoal(),
      loadResumableSession(),
      repository.latestCompletedRoutine(
        userId: userId,
        locale: locale.languageCode,
      ),
    ]);
    if (!ref.mounted) return null;
    final session = values[1] as RoutineSessionSnapshot?;
    final name = session == null
        ? null
        : await repository.routineName(
            routineId: session.routineId,
            locale: locale.languageCode,
          );
    if (!ref.mounted) return null;
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

  final initialDashboard = await load();
  if (!ref.mounted || initialDashboard == null) return;
  yield initialDashboard;
  await for (final _ in repository.watchChanges(userId: userId)) {
    final dashboard = await load();
    if (!ref.mounted || dashboard == null) return;
    yield dashboard;
  }
}
