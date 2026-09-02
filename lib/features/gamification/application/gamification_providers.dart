import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_gamification_repository.dart';
import '../domain/gamification_repository.dart';
import '../domain/weekly_goal_progress.dart';

part 'gamification_providers.g.dart';

@riverpod
GamificationRepository gamificationRepository(Ref ref) {
  final userId = ref.watch(authControllerProvider).value?.activeUserId;
  if (userId == null) throw StateError('No active user');
  return DriftGamificationRepository(
    ref.watch(appDatabaseProvider),
    activeUserId: userId,
  );
}

/// Read-only local-first completion summary. Invalidating this provider retries
/// a transient database/profile error without creating any reward state.
@riverpod
Future<WeeklyGoalProgress> weeklyGoalProgress(Ref ref) =>
    ref.watch(gamificationRepositoryProvider).currentWeeklyGoal();
