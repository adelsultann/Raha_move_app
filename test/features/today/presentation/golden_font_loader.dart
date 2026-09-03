import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;

/// Loads the CI-provisioned Arabic font used only by Today visual tests.
///
/// Font bytes stay outside source control. The pinned source and checksum are
/// documented in the repository setup instructions.
abstract final class GoldenFontLoader {
  static const arabicFamily = 'RahaGoldenArabic';
  static const latinFamily = 'RahaGoldenLatin';
  static const arabicEnvironmentKey = 'RAHA_GOLDEN_FONT_PATH';
  static const latinEnvironmentKey = 'RAHA_GOLDEN_LATIN_FONT_PATH';

  static Future<void> load() async {
    await Future.wait([
      _loadFont(arabicEnvironmentKey, arabicFamily),
      _loadFont(latinEnvironmentKey, latinFamily),
    ]);
  }

  static Future<void> _loadFont(String environmentKey, String family) async {
    final path = Platform.environment[environmentKey];
    if (path == null || path.isEmpty) {
      throw StateError(
        '$environmentKey must point to the provisioned Arabic golden-test font.',
      );
    }
    final file = File(path);
    if (!await file.exists()) {
      throw StateError(
        '$environmentKey does not point to a readable font file.',
      );
    }
    final bytes = await file.readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}
