/// Bounded exponential backoff for failed outbox operations.
///
/// The delay before an attempt grows exponentially from [baseDelay] but is
/// capped at [maxDelay], so a permanently unreachable server does not push the
/// next attempt arbitrarily far into the future. After [maxAttempts] failed
/// attempts an operation is considered exhausted and stops auto-retrying.
final class BackoffPolicy {
  const BackoffPolicy({
    this.baseDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(minutes: 5),
    this.maxAttempts = 6,
  }) : assert(maxAttempts > 0, 'maxAttempts must be positive');

  final Duration baseDelay;
  final Duration maxDelay;
  final int maxAttempts;

  /// Delay to wait before the attempt numbered [attemptNumber] (1-based).
  ///
  /// `attemptNumber == 1` returns [baseDelay]; each subsequent attempt doubles
  /// the delay until it reaches [maxDelay]. The result never exceeds
  /// [maxDelay], which is the bound required by the sync retry contract.
  Duration delayForAttempt(int attemptNumber) {
    if (attemptNumber <= 1) return baseDelay;
    var delay = baseDelay;
    for (var attempt = 1; attempt < attemptNumber; attempt++) {
      if (delay >= maxDelay) return maxDelay;
      final doubled = delay * 2;
      delay = doubled > maxDelay ? maxDelay : doubled;
    }
    return delay;
  }

  /// Whether [attemptCount] failed attempts have exhausted the retry budget.
  bool isExhausted(int attemptCount) => attemptCount >= maxAttempts;
}
