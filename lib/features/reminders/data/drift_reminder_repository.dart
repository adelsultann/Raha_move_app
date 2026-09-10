import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/reminder_repository.dart';
import '../domain/reminder_schedule.dart';

final class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<ReminderSchedule?> read(String userId) async {
    final row = await (_database.select(
      _database.localReminderSchedules,
    )..where((row) => row.userId.equals(userId))).getSingleOrNull();
    if (row == null) return null;
    final parts = row.localTime.split(':');
    final days = (jsonDecode(row.daysOfWeekJson) as List<dynamic>)
        .cast<int>()
        .toSet();
    return ReminderSchedule(
      id: row.id,
      userId: row.userId,
      hour: int.parse(parts.first),
      minute: int.parse(parts.last),
      daysOfWeek: days,
      timezone: row.timezone,
      enabled: row.enabled,
    );
  }

  @override
  Future<void> save(ReminderSchedule schedule) => _database
      .into(_database.localReminderSchedules)
      .insertOnConflictUpdate(
        LocalReminderSchedulesCompanion.insert(
          id: schedule.id,
          userId: schedule.userId,
          localTime:
              '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}',
          daysOfWeekJson: jsonEncode(schedule.daysOfWeek.toList()..sort()),
          timezone: schedule.timezone,
          enabled: Value(schedule.enabled),
          syncState: const Value(SyncState.synced),
          localUpdatedAt: _clock().toUtc(),
        ),
      );

  @override
  Future<void> remove(String userId) => (_database.delete(
    _database.localReminderSchedules,
  )..where((row) => row.userId.equals(userId))).go();
}
