/// Owns the stable local identity and the re-key that promotes a guest identity
/// to a Supabase auth uid while preserving local history.
abstract interface class GuestIdentityStore {
  /// Returns the current local user id, minting and persisting a fresh guest
  /// UUID when none exists yet. Stable across application restarts.
  Future<String> currentOrCreateGuestId();

  /// Returns the current local user id. Throws when no identity exists yet.
  Future<String> currentLocalUserId();

  /// Creates the local profile and preferences for [userId] when absent, using
  /// safe defaults (`ar`, `Asia/Riyadh`, weekly goal 3, `beginner`). Idempotent.
  Future<void> ensureProfile(String userId);

  /// Re-keys every user-owned local row from [guestId] to [supabaseUid] in a
  /// single transaction, preserving all non-identity columns. No-op when the
  /// ids are equal. Used to promote a guest identity to a linked Supabase
  /// identity.
  Future<void> linkGuestToSupabaseUid({
    required String guestId,
    required String supabaseUid,
  });

  /// Points the active local identity at an already-known [accountId] WITHOUT
  /// re-keying another identity's data (isolation). Creates the account's local
  /// profile when absent. Used for signing into an EXISTING account, where
  /// guest history must NOT be merged into the account.
  Future<void> activateAccount(String accountId);

  /// Mints a fresh local guest id for the post-sign-out session.
  Future<void> resetForSignOut();
}
