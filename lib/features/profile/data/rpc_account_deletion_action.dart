import 'dart:convert';

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
      // Make the privacy boundary durable before the request crosses the
      // network. A process death after a successful RPC can therefore never
      // restore this account's old local session or data on the next launch.
      await _cleanup.prepareDeletionRequest(userId: userId);
      final envelope = await _gateway.rpc('request_account_deletion', const {});
      if (envelope?['version'] != 'raha_064_deletion_v1' ||
          envelope?['status'] != 'requested') {
        return AccountDeletionResult.failed;
      }
      final cleanup = await _cleanup.clearAcceptedRequest(
        userId: userId,
        mediaOwnerId: _mediaOwnerId() ?? userId,
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
  /// Arms fail-closed local recovery before a deletion RPC is sent. An unknown
  /// RPC outcome is safer to recover as cleanup than to restore old data.
  Future<void> prepareDeletionRequest({required String userId});

  Future<AccountDeletionCleanupResult> clearAcceptedRequest({
    required String userId,
    required String? mediaOwnerId,
  });
}

enum AccountDeletionCleanupResult { completed, pending }

/// Idempotent cleanup after a verified accepted request. The durable marker is
/// the privacy boundary: while it exists, startup must not restore normal app
/// routes. A new guest identity is created only after private media metadata,
/// user rows, and local credentials have all been removed.
final class DriftAccountDeletionCleanup implements AccountDeletionCleanup {
  static const markerPrefix = 'account_deletion_cleanup_';
  DriftAccountDeletionCleanup(
    this._database,
    this._auth,
    this._identities,
    this._mediaLifecycle, {
    this.cancelReminders,
  });

  final AppDatabase _database;
  final AuthRepository _auth;
  final GuestIdentityStore _identities;
  final Future<MediaCacheLifecycle> Function() _mediaLifecycle;
  final Future<void> Function(String userId)? cancelReminders;

  @override
  Future<void> prepareDeletionRequest({required String userId}) =>
      _writeMarker(userId: userId, mediaOwnerId: userId);

  /// Resumes only locally durable, already-accepted deletion requests. This
  /// deliberately has no RPC dependency: retrying must remain safe offline and
  /// must never submit a second deletion request.
  Future<AccountDeletionCleanupResult> recoverPending() async {
    final entries = await _database.select(_database.environmentEntries).get();
    for (final entry in entries.where(
      (entry) => entry.key.startsWith(markerPrefix),
    )) {
      final userId = entry.key.substring(markerPrefix.length);
      final mediaOwnerId = _mediaOwnerFromMarker(entry.value) ?? userId;
      if (userId.isEmpty ||
          await clearAcceptedRequest(
                userId: userId,
                mediaOwnerId: mediaOwnerId,
              ) ==
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
    final marker = '$markerPrefix$userId';
    final ownerToPurge = mediaOwnerId ?? userId;
    try {
      await _writeMarker(userId: userId, mediaOwnerId: ownerToPurge);
      await cancelReminders?.call(userId);
      await (await _mediaLifecycle()).purgeOwner(ownerToPurge);
      await LocalUserDataRepository(
        _database,
        activeUserId: userId,
        clock: DateTime.now,
      ).purgeActiveUser();
      await (_database.delete(
        _database.environmentEntries,
      )..where((row) => row.key.equals('telemetry_consent_$userId'))).go();
      // The request was already accepted. Credential removal must work offline.
      await _auth.clearLocalSession();
      // Server-wide revocation is worthwhile but cannot block a fresh offline
      // guest after the local privacy boundary has been cleared.
      try {
        await _auth.signOut();
      } catch (_) {}
      // Do this last: creating a guest profile earlier would restore normal
      // guest state while deletion cleanup was still incomplete.
      await _identities.resetForSignOut();
      await (_database.delete(
        _database.environmentEntries,
      )..where((row) => row.key.equals(marker))).go();
      return AccountDeletionCleanupResult.completed;
    } catch (_) {
      return AccountDeletionCleanupResult.pending;
    }
  }

  String? _mediaOwnerFromMarker(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final owner = decoded['media_owner_id'];
        return owner is String && owner.isNotEmpty ? owner : null;
      }
    } on FormatException {
      // Legacy `pending` markers safely fall back to the deleted user id.
    }
    return null;
  }

  Future<void> _writeMarker({
    required String userId,
    required String mediaOwnerId,
  }) => _database
      .into(_database.environmentEntries)
      .insertOnConflictUpdate(
        EnvironmentEntriesCompanion.insert(
          key: '$markerPrefix$userId',
          // The owner id is needed only to resume local cache cleanup. It is never
          // sent remotely or included in telemetry.
          value: jsonEncode({'media_owner_id': mediaOwnerId}),
        ),
      );
}
