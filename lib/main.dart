import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/catalog_bootstrap_gate.dart';
import 'app/bootstrap/catalog_bootstrap_providers.dart';
import 'app/bootstrap/secure_local_storage.dart';
import 'app/bootstrap/supabase_bootstrap.dart';
import 'features/authentication/presentation/auth_gate.dart';
import 'features/media/application/media_cache_auth_observer.dart';
import 'features/onboarding/presentation/onboarding_gate.dart';
import 'features/profile/presentation/account_deletion_recovery_gate.dart';
import 'features/profile/data/account_deletion_startup_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabaseAfterDeletionPreflight(
    deletionGuard: _deletionStartupGuard(),
    initialize: initializeSupabaseIfConfigured,
  );
  runApp(
    const ProviderScope(
      child: AccountDeletionRecoveryGate(
        child: MediaCacheAuthObserver(
          child: CatalogBootstrapGate(
            child: AuthGate(child: OnboardingGate(child: RahaMoveApp())),
          ),
        ),
      ),
    ),
  );
}

AccountDeletionStartupGuard _deletionStartupGuard() {
  final database = createAppDatabase();
  return AccountDeletionStartupGuard(
    hasPendingCleanup: () async {
      try {
        return await hasPendingAccountDeletionCleanup(database);
      } finally {
        await database.close();
      }
    },
    clearPersistedSession: () => SecureLocalStorage().removePersistedSession(),
  );
}
