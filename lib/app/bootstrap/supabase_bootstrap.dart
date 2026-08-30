import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes the public Supabase client only when both non-secret build
/// values are present. Local tests and the bundled offline experience require
/// neither value and never contact a backend.
Future<void> initializeSupabaseIfConfigured() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isEmpty && publishableKey.isEmpty) return;
  if (url.isEmpty || publishableKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be configured together',
    );
  }
  final uri = Uri.tryParse(url);
  final localHttp =
      uri?.scheme == 'http' &&
      (uri?.host == '127.0.0.1' || uri?.host == 'localhost');
  if (uri == null || (!uri.isScheme('https') && !localHttp)) {
    throw StateError('SUPABASE_URL must use HTTPS outside local development');
  }
  await Supabase.initialize(url: url, publishableKey: publishableKey);
}
