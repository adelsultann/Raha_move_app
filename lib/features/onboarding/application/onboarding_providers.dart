import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_onboarding_repository.dart';
import '../domain/onboarding_repository.dart';

part 'onboarding_providers.g.dart';

/// Injectable onboarding persistence boundary, backed by the local Drift
/// database. Tests override this with an in-memory fake.
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) =>
    DriftOnboardingRepository(ref.watch(appDatabaseProvider));
