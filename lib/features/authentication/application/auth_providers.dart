import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/drift_guest_identity_store.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/guest_identity_store.dart';

part 'auth_providers.g.dart';

/// Injectable authentication boundary. Uses the live Supabase client when it
/// has been initialized; otherwise falls back to the offline repository so the
/// app is guest-capable and tests run without a backend.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => resolveLiveAuthRepository();

/// Injectable local identity store backed by Drift.
@Riverpod(keepAlive: true)
GuestIdentityStore guestIdentityStore(Ref ref) =>
    DriftGuestIdentityStore(ref.watch(appDatabaseProvider));
