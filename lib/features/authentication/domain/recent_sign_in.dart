/// Tracks a credential-backed sign-in performed in this process.
///
/// It intentionally does not survive restart: a restored session is not proof
/// of a recent credential check and sensitive actions must fail closed.
final class RecentSignInTracker {
  RecentSignInTracker({
    DateTime Function()? clock,
    this.window = const Duration(minutes: 15),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Duration window;
  DateTime? _verifiedAt;

  bool get isRecent {
    final verifiedAt = _verifiedAt;
    if (verifiedAt == null) return false;
    final elapsed = _clock().toUtc().difference(verifiedAt);
    return !elapsed.isNegative && elapsed <= window;
  }

  void markVerified({DateTime? at}) => _verifiedAt = (at ?? _clock()).toUtc();

  void clear() => _verifiedAt = null;
}
