import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/reminder_repository.dart';

/// Stores only the local no-repeat-prompt choice; it never contains reminder
/// content, health information, or notification payloads.
final class SecureReminderPermissionStore implements ReminderPermissionStore {
  SecureReminderPermissionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  String _key(String userId) => 'raha.reminder.permission-denied.$userId';
  @override
  Future<bool> wasDenied(String userId) async =>
      (await _storage.read(key: _key(userId))) == 'true';
  @override
  Future<void> recordDenied(String userId) =>
      _storage.write(key: _key(userId), value: 'true');
  @override
  Future<void> clearDenied(String userId) => _storage.delete(key: _key(userId));
}
