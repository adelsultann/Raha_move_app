import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/authentication/domain/auth_account.dart';
import 'package:raha_move/features/authentication/domain/auth_failure.dart';
import 'package:raha_move/features/authentication/domain/auth_repository.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/authentication/domain/guest_identity_store.dart';

void main() {
  test('build returns a guest state immediately without a network', () async {
    final harness = _Harness(
      repository: _FakeAuthRepository(isConfigured: false),
    );
    addTearDown(harness.dispose);

    final state = await harness.container.read(authControllerProvider.future);

    expect(state.status, AuthStatus.guest);
    expect(state.activeUserId, 'guest-1');
    expect(state.hasSupabaseIdentity, isFalse);
  });

  test('guest links anonymously and re-keys its history', () async {
    final store = _FakeGuestIdentityStore(currentId: 'guest-1');
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: null,
      anonymousAccount: const AuthAccount(
        id: 'anon-1',
        isAnonymous: true,
        emailConfirmed: false,
      ),
    );
    final harness = _Harness(repository: repository, store: store);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    // Allow the background link to complete.
    await _pumpEventQueue();

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.status, AuthStatus.anonymous);
    expect(state.activeUserId, 'anon-1');
    expect(store.linked, [('guest-1', 'anon-1')]);
    expect(store.activated, isEmpty);
  });

  test('upgrade preserves history (uid unchanged, no re-key)', () async {
    final store = _FakeGuestIdentityStore(currentId: 'anon-1');
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: const AuthAccount(
        id: 'anon-1',
        isAnonymous: true,
        emailConfirmed: false,
      ),
      convertedAccount: const AuthAccount(
        id: 'anon-1',
        isAnonymous: false,
        emailConfirmed: true,
      ),
    );
    final harness = _Harness(repository: repository, store: store);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await _pumpEventQueue();

    await harness.container
        .read(authControllerProvider.notifier)
        .convertAnonymousToEmail(email: 'a@example.com', password: 'secret1');

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.status, AuthStatus.authenticated);
    expect(state.activeUserId, 'anon-1');
    expect(state.emailConfirmed, isTrue);
    expect(store.linked, isEmpty);
  });

  test(
    'sign-in to an existing account switches identity without merging',
    () async {
      final store = _FakeGuestIdentityStore(currentId: 'guest-1');
      final repository = _FakeAuthRepository(
        isConfigured: true,
        restoredAccount: null,
        emailAccount: const AuthAccount(
          id: 'account-b',
          isAnonymous: false,
          emailConfirmed: true,
        ),
      );
      final harness = _Harness(repository: repository, store: store);
      addTearDown(harness.dispose);

      await harness.container.read(authControllerProvider.future);
      await harness.container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'b@example.com', password: 'secret1');

      final state = harness.container.read(authControllerProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.activeUserId, 'account-b');
      expect(store.activated, ['account-b']);
      expect(store.linked, isEmpty);
    },
  );

  test('logout clears the session and mints a fresh local id', () async {
    final store = _FakeGuestIdentityStore(currentId: 'anon-1');
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: const AuthAccount(
        id: 'anon-1',
        isAnonymous: true,
        emailConfirmed: false,
      ),
    );
    final harness = _Harness(repository: repository, store: store);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await _pumpEventQueue();

    await harness.container.read(authControllerProvider.notifier).signOut();

    final state = harness.container.read(authControllerProvider).value!;
    expect(repository.signedOut, isTrue);
    expect(store.resetCount, 1);
    expect(state.status, AuthStatus.guest);
    expect(state.activeUserId, isNot('anon-1'));
  });

  test('invalid credentials surfaces a failure', () async {
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: null,
      emailError: const AuthFailureException(AuthFailure.invalidCredentials),
    );
    final harness = _Harness(repository: repository);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await harness.container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'a@example.com', password: 'wrong');

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.failure, AuthFailure.invalidCredentials);
    expect(state.isBusy, isFalse);
  });

  test('offline sign-in surfaces networkOffline', () async {
    final repository = _FakeAuthRepository(isConfigured: false);
    final harness = _Harness(repository: repository);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await harness.container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'a@example.com', password: 'secret1');

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.failure, AuthFailure.networkOffline);
  });

  test('cancelled failure is surfaced without crashing', () async {
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: null,
      emailError: const AuthFailureException(AuthFailure.cancelled),
    );
    final harness = _Harness(repository: repository);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await harness.container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'a@example.com', password: 'secret1');

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.failure, AuthFailure.cancelled);
  });

  test(
    'retryAnonymousLink re-attempts the anonymous link after a failure',
    () async {
      var attempts = 0;
      final store = _FakeGuestIdentityStore(currentId: 'guest-1');
      final repository = _FakeAuthRepository(
        isConfigured: true,
        restoredAccount: null,
        onAnonymous: () async {
          attempts++;
          if (attempts == 1) {
            throw const AuthFailureException(AuthFailure.networkOffline);
          }
          return const AuthAccount(
            id: 'anon-1',
            isAnonymous: true,
            emailConfirmed: false,
          );
        },
      );
      final harness = _Harness(repository: repository, store: store);
      addTearDown(harness.dispose);

      await harness.container.read(authControllerProvider.future);
      await _pumpEventQueue();
      expect(
        harness.container.read(authControllerProvider).value!.failure,
        AuthFailure.networkOffline,
      );

      await harness.container
          .read(authControllerProvider.notifier)
          .retryAnonymousLink();

      final state = harness.container.read(authControllerProvider).value!;
      expect(state.status, AuthStatus.anonymous);
      expect(state.activeUserId, 'anon-1');
      expect(store.linked, [('guest-1', 'anon-1')]);
    },
  );

  test('sign-up needing confirmation sets pendingEmail', () async {
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: null,
      signUpOutcome: const SignUpOutcome.needsConfirmation('a@example.com'),
    );
    final harness = _Harness(repository: repository);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await harness.container
        .read(authControllerProvider.notifier)
        .signUpWithEmail(email: 'a@example.com', password: 'secret1');

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.pendingEmail, 'a@example.com');
    expect(state.status, AuthStatus.guest);
  });

  test(
    'sign-in to an unconfirmed account surfaces unconfirmed + pendingEmail',
    () async {
      final repository = _FakeAuthRepository(
        isConfigured: true,
        restoredAccount: null,
        emailError: const AuthFailureException(AuthFailure.unconfirmed),
      );
      final harness = _Harness(repository: repository);
      addTearDown(harness.dispose);

      await harness.container.read(authControllerProvider.future);
      await harness.container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'a@example.com', password: 'secret1');

      final state = harness.container.read(authControllerProvider).value!;
      expect(state.failure, AuthFailure.unconfirmed);
      expect(state.pendingEmail, 'a@example.com');
    },
  );

  test('clearFailure resets failure and pendingEmail', () async {
    final repository = _FakeAuthRepository(
      isConfigured: true,
      restoredAccount: null,
      emailError: const AuthFailureException(AuthFailure.invalidCredentials),
    );
    final harness = _Harness(repository: repository);
    addTearDown(harness.dispose);

    await harness.container.read(authControllerProvider.future);
    await harness.container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'a@example.com', password: 'wrong');
    harness.container.read(authControllerProvider.notifier).clearFailure();

    final state = harness.container.read(authControllerProvider).value!;
    expect(state.failure, isNull);
    expect(state.pendingEmail, isNull);
  });
}

/// Lets the background anonymous-link microtask/futures settle.
Future<void> _pumpEventQueue() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

final class _Harness {
  _Harness({required AuthRepository repository, GuestIdentityStore? store})
    : container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          guestIdentityStoreProvider.overrideWithValue(
            store ?? _FakeGuestIdentityStore(currentId: 'guest-1'),
          ),
        ],
      );

  final ProviderContainer container;

  void dispose() => container.dispose();
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.isConfigured,
    this.restoredAccount,
    this.anonymousAccount,
    this.emailAccount,
    this.emailError,
    this.signUpOutcome,
    this.convertedAccount,
    this.onAnonymous,
  });

  @override
  final bool isConfigured;

  final AuthAccount? restoredAccount;
  final AuthAccount? anonymousAccount;
  final AuthAccount? emailAccount;
  final AuthFailureException? emailError;
  final SignUpOutcome? signUpOutcome;
  final AuthAccount? convertedAccount;
  final Future<AuthAccount> Function()? onAnonymous;

  bool signedOut = false;
  int resendCalls = 0;

  @override
  Stream<AuthAccount?> watchAccount() =>
      Stream<AuthAccount?>.value(restoredAccount);

  @override
  Future<AuthAccount?> restoreSession() async => restoredAccount;

  @override
  Future<AuthAccount> signInAnonymously() async {
    final handler = onAnonymous;
    if (handler != null) return handler();
    final account = anonymousAccount;
    if (account != null) return account;
    throw const AuthFailureException(AuthFailure.networkOffline);
  }

  @override
  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final error = emailError;
    if (error != null) throw error;
    final account = emailAccount;
    if (account != null) return account;
    throw const AuthFailureException(AuthFailure.networkOffline);
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final outcome = signUpOutcome;
    if (outcome != null) return outcome;
    throw const AuthFailureException(AuthFailure.networkOffline);
  }

  @override
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    final account = convertedAccount;
    if (account != null) return account;
    throw const AuthFailureException(AuthFailure.networkOffline);
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    resendCalls++;
  }
}

final class _FakeGuestIdentityStore implements GuestIdentityStore {
  _FakeGuestIdentityStore({required this.currentId});

  String currentId;
  final List<(String, String)> linked = [];
  final List<String> activated = [];
  int resetCount = 0;
  int ensureProfileCalls = 0;

  @override
  Future<String> currentOrCreateGuestId() async => currentId;

  @override
  Future<String> currentLocalUserId() async => currentId;

  @override
  Future<void> ensureProfile(String userId) async {
    ensureProfileCalls++;
  }

  @override
  Future<void> linkGuestToSupabaseUid({
    required String guestId,
    required String supabaseUid,
  }) async {
    if (guestId == supabaseUid) return;
    linked.add((guestId, supabaseUid));
    currentId = supabaseUid;
  }

  @override
  Future<void> activateAccount(String accountId) async {
    activated.add(accountId);
    currentId = accountId;
  }

  @override
  Future<void> resetForSignOut() async {
    resetCount++;
    currentId = 'guest-fresh';
  }
}
