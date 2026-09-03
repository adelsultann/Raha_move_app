import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/today_repository.dart';

/// Local-only Today history reader. Network and sync SDKs deliberately do not
/// participate, so completed offline work is immediately available.
final class DriftTodayRepository implements TodayRepository {
  DriftTodayRepository(this._database);

  final AppDatabase _database;

  @override
  Future<TodayCompletedRoutine?> latestCompletedRoutine({
    required String userId,
    required String locale,
  }) async {
    final session =
        await (_database.select(_database.localRoutineSessions)
              ..where(
                (row) =>
                    row.userId.equals(userId) & row.status.equals('completed'),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.completedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (session == null || session.completedAt == null) return null;

    final name = await routineName(
      routineId: session.routineId,
      locale: locale,
    );
    if (name == null) return null;

    return TodayCompletedRoutine(
      routineId: session.routineId,
      sessionId: session.id,
      name: name,
      completedAt: session.completedAt!,
    );
  }

  @override
  Future<String?> routineName({
    required String routineId,
    required String locale,
  }) async {
    final translation =
        await (_database.select(_database.localRoutineTranslations)..where(
              (row) =>
                  row.routineId.equals(routineId) & row.locale.equals(locale),
            ))
            .getSingleOrNull() ??
        await (_database.select(_database.localRoutineTranslations)..where(
              (row) =>
                  row.routineId.equals(routineId) & row.locale.equals('en'),
            ))
            .getSingleOrNull();
    return translation?.name;
  }

  @override
  Stream<void> watchChanges({required String userId}) => Stream.multi((
    controller,
  ) {
    final subscriptions = [
      (_database.select(_database.localRoutineSessions)
            ..where((row) => row.userId.equals(userId)))
          .watch()
          .listen((_) => controller.add(null), onError: controller.addError),
      (_database.select(_database.localProgressProjections)
            ..where((row) => row.userId.equals(userId)))
          .watch()
          .listen((_) => controller.add(null), onError: controller.addError),
      (_database.select(_database.localProfiles)
            ..where((row) => row.userId.equals(userId)))
          .watch()
          .listen((_) => controller.add(null), onError: controller.addError),
    ];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  }, isBroadcast: true);
}
