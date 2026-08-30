import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/catalog_bootstrap_gate.dart';
import 'app/bootstrap/supabase_bootstrap.dart';
import 'features/media/application/media_cache_auth_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabaseIfConfigured();
  runApp(
    const ProviderScope(
      child: MediaCacheAuthObserver(
        child: CatalogBootstrapGate(child: RahaMoveApp()),
      ),
    ),
  );
}
