import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/authentication/data/drift_guest_identity_store.dart';
import 'package:raha_move/features/authentication/domain/auth_account.dart';
import 'package:raha_move/features/authentication/domain/auth_repository.dart';
import 'package:raha_move/features/media/application/media_cache_lifecycle.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:raha_move/features/authentication/domain/recent_sign_in.dart';
import 'package:raha_move/features/profile/data/rpc_account_deletion_action.dart';
import 'package:raha_move/features/profile/domain/account_deletion_action.dart';
import 'package:raha_move/features/sync/data/sync_rpc_gateway.dart';

void main() {
  test(
    'registered account fails closed before RPC without recent sign-in',
    () async {
      final gateway = _Gateway();
      final action = RpcAccountDeletionAction(
        gateway,
        RecentSignInTracker(),
        () => 'user-1',
        () => 'user-1',
        _Cleanup(),
      );
      expect(
        await action.requestDeletion(isRegisteredAccount: true),
        AccountDeletionResult.requiresRecentSignIn,
      );
      expect(gateway.calls, isEmpty);
    },
  );

  test(
    'restart retries only accepted local cleanup and removes its marker',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.environmentEntries)
          .insert(
            EnvironmentEntriesCompanion.insert(
              key: 'account_deletion_cleanup_user-1',
              value: 'pending',
            ),
          );
      final identity = DriftGuestIdentityStore(
        database,
        uuidGenerator: () => 'fresh',
      );
      await identity.currentOrCreateGuestId();
      final auth = _Auth();
      final cache = _Cache();
      final cleanup = DriftAccountDeletionCleanup(
        database,
        auth,
        identity,
        () async => MediaCacheLifecycle(cache: cache, files: _Files()),
      );

      expect(
        await cleanup.recoverPending(),
        AccountDeletionCleanupResult.completed,
      );
      expect(await database.select(database.environmentEntries).get(), isEmpty);
      expect(auth.signOutCalls, 1);
      expect(cache.purged, ['user-1']);

      // A second startup has no marker, creates no additional guest and repeats
      // neither local credential removal nor any remote action.
      expect(
        await cleanup.recoverPending(),
        AccountDeletionCleanupResult.completed,
      );
      expect(auth.signOutCalls, 1);
      expect(await identity.currentLocalUserId(), 'fresh');
    },
  );

  test(
    'failed restart cleanup retains marker for a recoverable repeated retry',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.environmentEntries)
          .insert(
            EnvironmentEntriesCompanion.insert(
              key: 'account_deletion_cleanup_user-1',
              value: 'pending',
            ),
          );
      final cleanup = DriftAccountDeletionCleanup(
        database,
        _Auth(),
        DriftGuestIdentityStore(database, uuidGenerator: () => 'fresh'),
        () async =>
            MediaCacheLifecycle(cache: _Cache(fail: true), files: _Files()),
      );
      expect(
        await cleanup.recoverPending(),
        AccountDeletionCleanupResult.pending,
      );
      expect(
        await cleanup.recoverPending(),
        AccountDeletionCleanupResult.pending,
      );
      expect(
        await (database.select(database.environmentEntries)
              ..where((e) => e.key.equals('account_deletion_cleanup_user-1')))
            .getSingleOrNull(),
        isNotNull,
      );
    },
  );

  test(
    'accepted anonymous request clears local state only after valid RPC',
    () async {
      final gateway = _Gateway();
      final cleanup = _Cleanup();
      final action = RpcAccountDeletionAction(
        gateway,
        RecentSignInTracker(),
        () => 'user-1',
        () => 'user-1',
        cleanup,
      );
      expect(
        await action.requestDeletion(isRegisteredAccount: false),
        AccountDeletionResult.accepted,
      );
      expect(gateway.calls, ['request_account_deletion']);
      expect(cleanup.calls, 1);
    },
  );

  test('malformed RPC response never clears data or claims success', () async {
    final gateway = _Gateway(
      response: {'version': 'wrong', 'status': 'requested'},
    );
    final cleanup = _Cleanup();
    final action = RpcAccountDeletionAction(
      gateway,
      RecentSignInTracker(),
      () => 'user-1',
      () => 'user-1',
      cleanup,
    );
    expect(
      await action.requestDeletion(isRegisteredAccount: false),
      AccountDeletionResult.failed,
    );
    expect(cleanup.calls, 0);
  });

  test(
    'accepted RPC with local cleanup pending is reported honestly',
    () async {
      final action = RpcAccountDeletionAction(
        _Gateway(),
        RecentSignInTracker(),
        () => 'user-1',
        () => 'user-1',
        _Cleanup(result: AccountDeletionCleanupResult.pending),
      );
      expect(
        await action.requestDeletion(isRegisteredAccount: false),
        AccountDeletionResult.acceptedWithPendingCleanup,
      );
    },
  );
}

final class _Gateway implements SyncRpcGateway {
  _Gateway({
    this.response = const {
      'version': 'raha_064_deletion_v1',
      'status': 'requested',
    },
  });
  final Map<String, dynamic> response;
  final calls = <String>[];
  @override
  bool get isConfigured => true;
  @override
  String? get currentUserId => 'user-1';
  @override
  Future<Map<String, dynamic>?> rpc(
    String function,
    Map<String, dynamic> args,
  ) async {
    calls.add(function);
    return response;
  }
}

final class _Cleanup implements AccountDeletionCleanup {
  _Cleanup({this.result = AccountDeletionCleanupResult.completed});
  int calls = 0;
  final AccountDeletionCleanupResult result;
  @override
  Future<AccountDeletionCleanupResult> clearAcceptedRequest({
    required String userId,
    required String? mediaOwnerId,
  }) async {
    calls++;
    return result;
  }
}

final class _Auth implements AuthRepository {
  int signOutCalls = 0;
  @override
  bool get isConfigured => false;
  @override
  Future<void> signOut() async => signOutCalls++;
  @override
  Future<void> clearLocalSession() async {}
  @override
  Stream<AuthAccount?> watchAccount() => const Stream.empty();
  @override
  Future<AuthAccount?> restoreSession() async => null;
  @override
  Future<AuthAccount> signInAnonymously() => throw UnimplementedError();
  @override
  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<void> resendConfirmation({required String email}) =>
      throw UnimplementedError();
}

final class _Cache implements MediaCacheIndex {
  _Cache({this.fail = false});
  final bool fail;
  final purged = <String>[];
  @override
  Future<List<CachedMedia>> allVerifiedByLeastRecentAccess() async =>
      fail ? throw StateError('purge interrupted') : const [];
  @override
  Future<void> purgeOwner(String ownerId) async {
    purged.add(ownerId);
  }

  @override
  Future<CachedMedia?> find({
    required String ownerId,
    required String mediaId,
  }) async => null;
  @override
  Future<void> put(CachedMedia media) async {}
  @override
  Future<void> remove({
    required String ownerId,
    required String mediaId,
  }) async {}
  @override
  Future<void> touch({
    required String ownerId,
    required String mediaId,
    required DateTime at,
  }) async {}
}

final class _Files implements MediaFileStore {
  @override
  Future<int?> availableBytes() async => null;
  @override
  Future<void> commitTemporary({
    required String temporaryPath,
    required String path,
  }) async {}
  @override
  Future<void> delete(String path) async {}
  @override
  Future<bool> exists(String path) async => false;
  @override
  String pathFor({
    required String ownerId,
    required String mediaId,
    required String checksumSha256,
  }) => '';
  @override
  Future<Uint8List> read(String path) async => Uint8List(0);
  @override
  Future<String> writeTemporary(Uint8List bytes) async => '';
}
