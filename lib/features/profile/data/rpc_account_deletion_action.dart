import '../../../core/database/app_database.dart';
import '../../authentication/domain/auth_repository.dart';
import '../../authentication/domain/guest_identity_store.dart';
import '../../authentication/domain/recent_sign_in.dart';
import '../../media/application/media_cache_lifecycle.dart';
import '../../sync/data/sync_rpc_gateway.dart';
import '../domain/account_deletion_action.dart';

/// Executes only the owner-facing `request_account_deletion` RPC contract.
/// The database service, not the app, performs deferred account destruction.
final class RpcAccountDeletionAction implements AccountDeletionAction {
  RpcAccountDeletionAction(
    this._gateway,
    this._recentSignIn,
    this._activeUserId,
    this._mediaOwnerId,
    this._cleanup,
  );

  final SyncRpcGateway _gateway;
  final RecentSignInTracker _recentSignIn;
  final String? Function() _activeUserId;
  final String? Function() _mediaOwnerId;
  final AccountDeletionCleanup _cleanup;

  @override
  Future<AccountDeletionResult> requestDeletion({
    required bool isRegisteredAccount,
  }) async {
    // A restored registered session is insufficient evidence of a recent
    // credential check. The UI must send the user through email sign-in first.
    if (isRegisteredAccount && !_recentSignIn.isRecent) {
      return AccountDeletionResult.requiresRecentSignIn;
    }
    final userId = _activeUserId();
    if (!_gateway.isConfigured ||
        userId == null ||
        _gateway.currentUserId != userId) {
      return AccountDeletionResult.unavailable;
    }
    try {
      final envelope = await _gateway.rpc('request_account_deletion', const {});
      if (envelope?['version'] != 'raha_064_deletion_v1' ||
          envelope?['status'] != 'requested') {
        return AccountDeletionResult.failed;
      }
      final cleanup = await _cleanup.clearAcceptedRequest(
        userId: userId,
        mediaOwnerId: _mediaOwnerId(),
      );
      return cleanup == AccountDeletionCleanupResult.completed
          ? AccountDeletionResult.accepted
          : AccountDeletionResult.acceptedWithPendingCleanup;
    } catch (_) {
      // Before acceptance we cannot know whether the request reached the
      // server, so never state that deletion was scheduled.
      return AccountDeletionResult.failed;
    }
  }
}

abstract interface class AccountDeletionCleanup {
  Future<AccountDeletionCleanupResult> clearAcceptedRequest({
    required String userId,
    required String? mediaOwnerId,
  });
}

enum AccountDeletionCleanupResult { completed, pending }

/// Idempotent cleanup after a verified accepted request. Credentials are
/// cleared last, so a local cleanup failure never leaves an honest "signed in"
/// UI after the secure session is already gone.
final class DriftAccountDeletionCleanup implements AccountDeletionCleanup {
  DriftAccountDeletionCleanup(
    this._database,
    this._auth,
    this._identities,
    this._mediaLifecycle,
  );

  final AppDatabase _database;
  final AuthRepository _auth;
  final GuestIdentityStore _identities;
  final Future<MediaCacheLifecycle> Function() _mediaLifecycle;

  /// Resumes only locally durable, already-accepted deletion requests. This
  /// deliberately has no RPC dependency: retrying must remain safe offline and
  /// must never submit a second deletion request.
  Future<AccountDeletionCleanupResult> recoverPending() async {
    final entries = await _database.select(_database.environmentEntries).get();
    for (final entry in entries.where(
      (entry) => entry.key.startsWith('account_deletion_cleanup_'),
    )) {
      final userId = entry.key.substring('account_deletion_cleanup_'.length);
      if (userId.isEmpty ||
          await clearAcceptedRequest(userId: userId, mediaOwnerId: userId) ==
              AccountDeletionCleanupResult.pending) {
        return AccountDeletionCleanupResult.pending;
      }
    }
    return AccountDeletionCleanupResult.completed;
  }

  @override
  Future<AccountDeletionCleanupResult> clearAcceptedRequest({
    required String userId,
    required String? mediaOwnerId,
  }) async {
    final marker = 'account_deletion_cleanup_$userId';
    try {
      await _database
          .into(_database.environmentEntries)
          .insertOnConflictUpdate(
            EnvironmentEntriesCompanion.insert(key: marker, value: 'pending'),
          );
      if (mediaOwnerId != null) {
        await (await _mediaLifecycle()).purgeOwner(mediaOwnerId);
      }
      await LocalUserDataRepository(
        _database,
        activeUserId: userId,
        clock: DateTime.now,
      ).purgeActiveUser();
      await (_database.delete(
        _database.environmentEntries,
      )..where((row) => row.key.equals('telemetry_consent_$userId'))).go();
      String? activeLocalUserId;
      try {
        activeLocalUserId = await _identities.currentLocalUserId();
      } catch (_) {
        // Startup recovery runs before auth has minted a new guest identity.
      }
      if (activeLocalUserId == userId) {
        await _identities.resetForSignOut();
      }
      // The request was already accepted. Credential removal must work offline.
      await _auth.clearLocalSession();
      // Server-wide revocation is worthwhile but cannot block a fresh offline
      // guest after the local privacy boundary has been cleared.
      try {
        await _auth.signOut();
      } catch (_) {}
      await (_database.delete(
        _database.environmentEntries,
      )..where((row) => row.key.equals(marker))).go();
      return AccountDeletionCleanupResult.completed;
    } catch (_) {
      return AccountDeletionCleanupResult.pending;
    }
  }
}
