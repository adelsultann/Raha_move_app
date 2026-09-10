import '../domain/reminder_repository.dart';
import '../domain/reminder_schedule.dart';

/// Reconciles a persisted reminder independently of the settings notifier.
/// Lifecycle and locale changes must work even when that notifier was never
/// built, and must never trigger a native permission prompt.
final class ReminderLifecycleService {
  const ReminderLifecycleService(this._repository, this._platform);

  final ReminderRepository _repository;
  final ReminderPlatform _platform;

  Future<void> reconcile({
    required String userId,
    required ReminderNotificationContent content,
  }) async {
    final schedule = await _repository.read(userId);
    if (schedule == null || !schedule.enabled) return;
    if (await _platform.permissionStatus() != ReminderPermission.granted) {
      return;
    }
    final updated = schedule.copyWith(
      timezone: await _platform.currentIanaTimezone(),
    );
    await _repository.save(updated);
    await _platform.schedule(updated, content);
  }
}
