import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/sync/domain/backoff_policy.dart';

void main() {
  const policy = BackoffPolicy(
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 4),
    maxAttempts: 6,
  );

  test('delay grows exponentially from the base delay', () {
    expect(policy.delayForAttempt(1), const Duration(seconds: 1));
    expect(policy.delayForAttempt(2), const Duration(seconds: 2));
    expect(policy.delayForAttempt(3), const Duration(seconds: 4));
  });

  test('delay is capped at maxDelay', () {
    expect(policy.delayForAttempt(3), const Duration(seconds: 4));
    expect(policy.delayForAttempt(4), const Duration(seconds: 4));
    expect(policy.delayForAttempt(100), const Duration(seconds: 4));
  });

  test('non-positive attempt numbers fall back to the base delay', () {
    expect(policy.delayForAttempt(0), const Duration(seconds: 1));
    expect(policy.delayForAttempt(-5), const Duration(seconds: 1));
  });

  test('isExhausted flips exactly at maxAttempts', () {
    expect(policy.isExhausted(0), isFalse);
    expect(policy.isExhausted(5), isFalse);
    expect(policy.isExhausted(6), isTrue);
    expect(policy.isExhausted(7), isTrue);
  });
}
