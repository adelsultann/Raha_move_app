import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_account.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';
import '../domain/guest_identity_store.dart';
import 'auth_providers.dart';

part 'auth_controller.g.dart';

/// App-owned authentication lifecycle.
///
/// It establishes a stable guest identity immediately (never blocking offline
/// use), then best-effort links an anonymous session and promotes the guest
/// identity to the Supabase uid. Explicit actions cover sign-in, sign-up,
/// anonymous→email upgrade, sign-out, retry, and confirmation resend.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final store = ref.watch(guestIdentityStoreProvider);

    final guestId = await store.currentOrCreateGuestId();
    await store.ensureProfile(guestId);

    // Best-effort anonymous link runs in the background; the guest experience
    // is available immediately and never waits on the network.
    unawaited(_attemptInitialLink(repository, store, guestId));

    return AuthState(activeUserId: guestId, status: AuthStatus.guest);
  }

  AuthState get _current =>
      state.value ??
      const AuthState(activeUserId: null, status: AuthStatus.guest);

  bool get _isIdleGuest =>
      _current.status == AuthStatus.guest && !_current.isBusy;

  Future<void> _attemptInitialLink(
    AuthRepository repository,
    GuestIdentityStore store,
    String guestId,
  ) async {
    if (!repository.isConfigured) return;

    final AuthAccount? account;
    try {
      account = await repository.restoreSession();
    } catch (_) {
      return; // remain guest
    }

    if (!_isIdleGuest) return; // a user action already took over

    if (account == null) {
      try {
        final anon = await repository.signInAnonymously();
        if (!_isIdleGuest) return;
        await store.linkGuestToSupabaseUid(
          guestId: guestId,
          supabaseUid: anon.id,
        );
        if (!_isIdleGuest) return;
        state = AsyncData(
          AuthState(activeUserId: anon.id, status: AuthStatus.anonymous),
        );
      } on AuthFailureException catch (e) {
        if (!_isIdleGuest) return;
        state = AsyncData(
          AuthState(
            activeUserId: guestId,
            status: AuthStatus.guest,
            failure: e.failure,
          ),
        );
      }
      return;
    }

    if (account.id == guestId) {
      state = AsyncData(_stateForAccount(account));
      return;
    }

    if (!_isIdleGuest) return;
    if (account.isAnonymous) {
      // Promote the guest/anon identity to the restored anon session.
      await store.linkGuestToSupabaseUid(
        guestId: guestId,
        supabaseUid: account.id,
      );
    } else {
      // Restored a permanent account: switch without merging guest history.
      await store.activateAccount(account.id);
    }
    state = AsyncData(_stateForAccount(account));
  }

  AuthState _stateForAccount(AuthAccount account) => AuthState(
    activeUserId: account.id,
    status: account.isAnonymous
        ? AuthStatus.anonymous
        : AuthStatus.authenticated,
    emailConfirmed: account.emailConfirmed,
  );

  void _setBusy() {
    state = AsyncData(_current.copyWith(isBusy: true, failure: null));
  }

  void _setFailure(AuthFailureException e, {String? pendingEmail}) {
    state = AsyncData(
      _current.copyWith(
        isBusy: false,
        failure: e.failure,
        pendingEmail: pendingEmail,
      ),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(guestIdentityStoreProvider);
    _setBusy();
    try {
      final account = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      // Existing-account path: switch identity without merging guest data.
      await store.activateAccount(account.id);
      state = AsyncData(_stateForAccount(account));
    } on AuthFailureException catch (e) {
      _setFailure(
        e,
        pendingEmail: e.failure == AuthFailure.unconfirmed ? email : null,
      );
    } catch (_) {
      _setFailure(const AuthFailureException(AuthFailure.unknown));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(guestIdentityStoreProvider);
    _setBusy();
    try {
      final outcome = await repository.signUpWithEmail(
        email: email,
        password: password,
      );
      switch (outcome) {
        case NeedsConfirmation(email: final confirmationEmail):
          state = AsyncData(
            _current.copyWith(isBusy: false, pendingEmail: confirmationEmail),
          );
        case SignedIn(account: final account):
          await store.activateAccount(account.id);
          state = AsyncData(_stateForAccount(account));
      }
    } on AuthFailureException catch (e) {
      _setFailure(
        e,
        pendingEmail: e.failure == AuthFailure.unconfirmed ? email : null,
      );
    } catch (_) {
      _setFailure(const AuthFailureException(AuthFailure.unknown));
    }
  }

  Future<void> convertAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    _setBusy();
    try {
      final account = await repository.convertAnonymousToEmail(
        email: email,
        password: password,
      );
      // The Supabase uid is unchanged; no re-key is needed.
      state = AsyncData(
        AuthState(
          activeUserId: account.id,
          status: AuthStatus.authenticated,
          emailConfirmed: account.emailConfirmed,
          pendingEmail: account.emailConfirmed ? null : email,
        ),
      );
    } on AuthFailureException catch (e) {
      _setFailure(
        e,
        pendingEmail: e.failure == AuthFailure.unconfirmed ? email : null,
      );
    } catch (_) {
      _setFailure(const AuthFailureException(AuthFailure.unknown));
    }
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(guestIdentityStoreProvider);
    _setBusy();
    try {
      await repository.signOut();
    } catch (_) {
      // Best-effort: local identity reset still proceeds.
    }
    try {
      await store.resetForSignOut();
      final freshId = await store.currentLocalUserId();
      state = AsyncData(
        AuthState(activeUserId: freshId, status: AuthStatus.guest),
      );
    } catch (_) {
      state = AsyncData(
        _current.copyWith(isBusy: false, failure: AuthFailure.unknown),
      );
    }
  }

  Future<void> retryAnonymousLink() async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(guestIdentityStoreProvider);
    final guestId = _current.activeUserId;
    if (guestId == null) return;
    _setBusy();
    try {
      if (!repository.isConfigured) {
        throw const AuthFailureException(AuthFailure.networkOffline);
      }
      final anon = await repository.signInAnonymously();
      await store.linkGuestToSupabaseUid(
        guestId: guestId,
        supabaseUid: anon.id,
      );
      state = AsyncData(
        AuthState(activeUserId: anon.id, status: AuthStatus.anonymous),
      );
    } on AuthFailureException catch (e) {
      state = AsyncData(
        AuthState(
          activeUserId: guestId,
          status: AuthStatus.guest,
          failure: e.failure,
        ),
      );
    } catch (_) {
      state = AsyncData(
        AuthState(
          activeUserId: guestId,
          status: AuthStatus.guest,
          failure: AuthFailure.unknown,
        ),
      );
    }
  }

  Future<void> resendConfirmation({required String email}) async {
    final repository = ref.read(authRepositoryProvider);
    _setBusy();
    try {
      await repository.resendConfirmation(email: email);
      state = AsyncData(_current.copyWith(isBusy: false));
    } on AuthFailureException catch (e) {
      _setFailure(e);
    } catch (_) {
      _setFailure(const AuthFailureException(AuthFailure.unknown));
    }
  }

  void clearFailure() {
    state = AsyncData(_current.copyWith(failure: null, pendingEmail: null));
  }
}
