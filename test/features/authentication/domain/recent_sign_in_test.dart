import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/authentication/domain/recent_sign_in.dart';

void main() {
  test('fresh credential sign-in is recent only inside its bounded window', () {
    var now = DateTime.utc(2026, 9, 7, 10);
    final tracker = RecentSignInTracker(clock: () => now);
    expect(tracker.isRecent, isFalse);
    tracker.markVerified();
    expect(tracker.isRecent, isTrue);
    now = now.add(const Duration(minutes: 16));
    expect(tracker.isRecent, isFalse);
  });

  test('restored and signed-out sessions fail the recent sign-in gate', () {
    final tracker = RecentSignInTracker(clock: () => DateTime.utc(2026, 9, 7));
    expect(tracker.isRecent, isFalse);
    tracker.markVerified();
    tracker.clear();
    expect(tracker.isRecent, isFalse);
  });
}
