/// Application-owned seam for the eventual trusted deletion workflow.
///
/// Implementations must perform any provider re-authentication and trusted
/// backend request. This mobile feature deliberately supplies no SDK behavior.
abstract interface class AccountDeletionAction {
  Future<AccountDeletionResult> requestDeletion({
    required bool isRegisteredAccount,
  });
}

enum AccountDeletionResult {
  accepted,
  acceptedWithPendingCleanup,
  requiresRecentSignIn,
  unavailable,
  failed,
}

final class UnavailableAccountDeletionAction implements AccountDeletionAction {
  const UnavailableAccountDeletionAction();

  @override
  Future<AccountDeletionResult> requestDeletion({
    required bool isRegisteredAccount,
  }) async => AccountDeletionResult.unavailable;
}
