import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [LocalStorage] that persists the Supabase auth session in platform-secure
/// storage (iOS Keychain, Android EncryptedSharedPreferences backed by the
/// Keystore, Windows Credential Manager, Linux libsecret) instead of plaintext
/// `SharedPreferences`.
///
/// Supabase passes the whole encoded session (including the refresh token)
/// through [persistSession]; storing it in secure storage keeps that credential
/// out of unencrypted app sandbox files and device/iCloud backups.
final class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({
    FlutterSecureStorage? storage,
    this.persistSessionKey = defaultSessionKey,
  }) : _storage = storage ?? const FlutterSecureStorage();

  /// Stable key for the persisted session. It is internal only; Supabase uses
  /// the value verbatim and never exposes it to the server.
  static const defaultSessionKey = 'raha_move_supabase_session';

  final FlutterSecureStorage _storage;
  final String persistSessionKey;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: persistSessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _storage.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: persistSessionKey, value: persistSessionString);
}
