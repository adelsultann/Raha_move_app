import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_preferences_repository.dart';
import '../domain/preferences_repository.dart';

part 'preferences_providers.g.dart';

/// Injectable preferences persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.
@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) =>
    DriftPreferencesRepository(ref.watch(appDatabaseProvider));
