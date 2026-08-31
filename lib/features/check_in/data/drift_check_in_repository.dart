import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../domain/check_in_answers.dart';
import '../domain/check_in_repository.dart';

/// Drift-backed [CheckInRepository].
///
/// Wraps the RAHA-023 local user-data repository so a completed check-in is
/// written in one transaction with its body-area rows and enqueued for sync.
/// Re-saving the same [checkInId] upserts in place (idempotent), so a retried
/// completion never creates a duplicate check-in.
final class DriftCheckInRepository implements CheckInRepository {
  DriftCheckInRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<void> save({
    required String userId,
    required String checkInId,
    required DateTime startedAt,
    required CheckInAnswers answers,
  }) {
    final now = _clock().toUtc();
    return LocalUserDataRepository(
      _database,
      activeUserId: userId,
      clock: () => now,
    ).saveCheckIn(
      checkIn: LocalCheckInsCompanion.insert(
        id: checkInId,
        userId: userId,
        bodyState: answers.bodyState.key,
        goalKey: answers.goalKey,
        availableMinutes: answers.availableMinutes,
        positionKey: Value(answers.positionKey),
        startedAt: startedAt,
        completedAt: Value(now),
        localUpdatedAt: now,
      ),
      bodyAreaKeys: answers.bodyAreaKeys,
    );
  }
}
