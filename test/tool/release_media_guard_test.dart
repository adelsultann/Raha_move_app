import '../../tool/release_media_guard.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows the approved fixture only in internal environments', () {
    expect(blockedFixturePathsForEnvironment('test'), isEmpty);
    expect(blockedFixturePathsForEnvironment('development'), isEmpty);
    expect(blockedFixturePathsForEnvironment('staging'), isEmpty);
  });

  test('blocks the committed fixture package for beta and production', () {
    final beta = blockedFixturePathsForEnvironment('beta');
    final production = blockedFixturePathsForEnvironment('production');

    expect(beta, hasLength(12));
    expect(production, beta);
    expect(
      beta,
      contains(
        'assets/starter_content/media/videos/free50/'
        'raha_ex_000101_free50_fixture_v1_1080.mp4',
      ),
    );
  });
}
