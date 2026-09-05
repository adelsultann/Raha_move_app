import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_progress_repository.dart';
import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';
import 'progress_week_calculator.dart';

part 'progress_providers.g.dart';

@riverpod
ProgressRepository progressRepository(Ref ref) {
  final userId = ref.watch(authControllerProvider).value?.activeUserId;
  if (userId == null) throw StateError('No active user');
  return DriftProgressRepository(
    ref.watch(appDatabaseProvider),
    activeUserId: userId,
  );
}

@riverpod
DateTime progressNow(Ref ref) => DateTime.now();

/// Re-emits when a profile timezone changes. An injected clock makes a week
/// boundary deterministic and callers can invalidate this provider on resume.
@riverpod
Stream<MovementDate> localCurrentProgressWeek(Ref ref) async* {
  final auth = await ref.watch(authControllerProvider.future);
  final userId = auth.activeUserId;
  if (userId == null) throw StateError('No active user');
  final database = ref.watch(appDatabaseProvider);
  final now = ref.watch(progressNowProvider).toUtc();
  await for (final profile in (database.select(
    database.localProfiles,
  )..where((row) => row.userId.equals(userId))).watchSingle()) {
    yield ProgressWeekCalculator().currentWeek(
      now: now,
      timezone: profile.timezone,
    );
  }
}

@riverpod
Stream<ProgressSummary> progressSummary(
  Ref ref,
  MovementDate weekStart,
) async* {
  final locale = await ref.watch(localeControllerProvider.future);
  yield* ref
      .watch(progressRepositoryProvider)
      .watchWeeklySummary(weekStart: weekStart, locale: locale.languageCode);
}
