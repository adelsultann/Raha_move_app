import 'dart:io';

const _fixturePaths = <String>[
  'assets/starter_content/media/videos/neck.gif',
  'assets/starter_content/media/videos/shoulder.mp4',
];

/// Returns fixture paths that must not be present in a distributable build.
/// Internal development and test builds are intentionally permitted to include
/// the approved RAHA-081 fixture package.
List<String> blockedFixturePathsForEnvironment(String environment) {
  if (environment != 'beta' && environment != 'production') return const [];
  return [for (final path in _fixturePaths) if (File(path).existsSync()) path];
}

void main(List<String> arguments) {
  final environment = arguments
      .where((argument) => argument.startsWith('--environment='))
      .map((argument) => argument.substring('--environment='.length))
      .singleOrNull;
  if (environment == null ||
      !const {'test', 'development', 'staging', 'beta', 'production'}.contains(
        environment,
      )) {
    stderr.writeln(
      'Usage: dart run tool/release_media_guard.dart '
      '--environment=<test|development|staging|beta|production>',
    );
    exitCode = 64;
    return;
  }

  final blocked = blockedFixturePathsForEnvironment(environment);
  if (blocked.isEmpty) return;
  stderr.writeln(
    'Internal RAHA-081 fixture media cannot be included in $environment builds:\n'
    '${blocked.join('\n')}',
  );
  exitCode = 1;
}
