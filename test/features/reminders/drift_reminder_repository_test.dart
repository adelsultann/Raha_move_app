import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/reminders/data/drift_reminder_repository.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';

void main() {
  test(
    'persists one local schedule and replaces updates without sync work',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              userId: 'user',
              preferredLocale: 'en',
              timezone: 'Asia/Riyadh',
              weeklyGoalDays: 3,
              localUpdatedAt: DateTime.utc(2026),
            ),
          );
      final repository = DriftReminderRepository(
        database,
        clock: () => DateTime.utc(2026),
      );
      final schedule = ReminderSchedule.dailyAtSix(
        id: 'reminder-user',
        userId: 'user',
        timezone: 'Asia/Riyadh',
      );
      await repository.save(schedule);
      await repository.save(
        schedule.copyWith(hour: 8, minute: 30, enabled: false),
      );
      final saved = await repository.read('user');
      expect(saved?.hour, 8);
      expect(saved?.minute, 30);
      expect(saved?.enabled, isFalse);
      final row = await database
          .select(database.localReminderSchedules)
          .getSingle();
      expect(row.syncState, SyncState.synced);
    },
  );
}
