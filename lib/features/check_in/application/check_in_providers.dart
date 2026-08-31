import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_check_in_repository.dart';
import '../domain/check_in_repository.dart';

part 'check_in_providers.g.dart';

/// Injectable check-in persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.
@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) =>
    DriftCheckInRepository(ref.watch(appDatabaseProvider));
