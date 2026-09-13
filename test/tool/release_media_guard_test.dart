import '../../tool/release_media_guard.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows the approved fixture only in internal environments', () {
    expect(blockedFixturePathsForEnvironment('test'), isEmpty);
    expect(blockedFixturePathsForEnvironment('development'), isEmpty);
    expect(blockedFixturePathsForEnvironment('staging'), isEmpty);
  });

  test('blocks the committed fixture package for beta and production', () {
    expect(blockedFixturePathsForEnvironment('beta'), hasLength(2));
    expect(blockedFixturePathsForEnvironment('production'), hasLength(2));
  });
}
