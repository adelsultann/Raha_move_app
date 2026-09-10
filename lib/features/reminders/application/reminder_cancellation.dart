import '../domain/reminder_repository.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Privacy boundary used before identity data is removed. A failed platform
/// cancellation is surfaced to the caller but never prevents local logout.
final class ReminderCancellation {
  ReminderCancellation(
    this._repository,
    this._platform, {
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();
  final ReminderRepository _repository;
  final ReminderPlatform _platform;
  final FlutterSecureStorage _storage;
  static const _prefix = 'raha.reminder.cancel.';

  Future<void> cancelForUser(String? userId) async {
    if (userId == null) return;
    final schedule = await _repository.read(userId);
    if (schedule != null) await cancelScheduleId(schedule.id);
  }

  /// Durable privacy queue: only Raha-owned deterministic schedule ids are
  /// retained, and each is retried before any new reminder can be scheduled.
  Future<void> cancelScheduleId(String scheduleId) async {
    // Storage may be unavailable in a degraded platform state; still attempt
    // immediate cancellation. On normal devices the queue is durable first.
    try {
      await _storage.write(key: '$_prefix$scheduleId', value: 'pending');
    } catch (_) {}
    await _platform.cancel(scheduleId);
    try {
      await _storage.delete(key: '$_prefix$scheduleId');
    } catch (_) {}
  }

  Future<void> retryPending() async {
    final values = await _storage.readAll();
    for (final key in values.keys.where((key) => key.startsWith(_prefix))) {
      final id = key.substring(_prefix.length);
      try {
        await _platform.cancel(id);
        await _storage.delete(key: key);
      } catch (_) {
        // Keep it durable for the next launch; never schedule it again.
      }
    }
  }
}
