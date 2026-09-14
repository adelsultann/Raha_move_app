import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/data/account_deletion_startup_guard.dart';
import 'secure_local_storage.dart';

/// Runs deletion recovery preflight before Supabase can restore a persisted
/// session or issue authenticated refresh traffic.
Future<void> initializeSupabaseAfterDeletionPreflight({
  required AccountDeletionStartupGuard deletionGuard,
  required Future<void> Function() initialize,
}) async {
  if (await deletionGuard.permitsSupabaseInitialization()) {
    await initialize();
  }
}

/// Initializes the public Supabase client only when both non-secret build
/// values are present. Local tests and the bundled offline experience require
/// neither value and never contact a backend.
Future<void> initializeSupabaseIfConfigured() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  const environment = String.fromEnvironment(
    'RAHA_ENV',
    defaultValue: 'development',
  );
  if (url.isEmpty && publishableKey.isEmpty) return;
  if (url.isEmpty || publishableKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be configured together',
    );
  }
  final uri = Uri.tryParse(url);
  final localDevelopment =
      environment == 'development' || environment == 'test';
  if (!isPermittedSupabaseUrl(uri, allowLocalHttp: localDevelopment)) {
    throw StateError('SUPABASE_URL must use HTTPS outside local development');
  }
  await Supabase.initialize(
    url: url,
    publishableKey: publishableKey,
    authOptions: FlutterAuthClientOptions(
      // Persist the auth session (including the refresh token) in
      // platform-secure storage rather than plaintext SharedPreferences.
      localStorage: SecureLocalStorage(),
    ),
  );
}

/// Validates the public Supabase API URL without accepting clear-text traffic
/// outside local development. `10.0.2.2` is Android Emulator's alias for the
/// host machine, where the local Supabase API commonly runs on port 54321.
bool isPermittedSupabaseUrl(Uri? uri, {required bool allowLocalHttp}) {
  if (uri == null) return false;
  if (uri.isScheme('https')) return true;
  return allowLocalHttp &&
      uri.isScheme('http') &&
      const {'127.0.0.1', 'localhost', '10.0.2.2'}.contains(uri.host);
}
