import 'content_release_contract.dart';
import 'content_release_source.dart';

/// Loads the bundled starter catalog so a fresh installation has a valid
/// catalog before its first network synchronization.
///
/// The asset string is injected so tests can supply a fixture without touching
/// the Flutter asset bundle; production wiring passes `rootBundle.loadString`.
final class BundledStarterContent {
  BundledStarterContent({required this._loadString});

  /// Stable asset path declared in `pubspec.yaml`.
  static const starterAssetPath =
      'assets/starter_content/manifests/starter_catalog.json';

  final Future<String> Function(String) _loadString;

  /// Loads and verifies the bundled starter release. Throws
  /// [ContentReleaseException] when the asset is absent, malformed, or fails
  /// its canonical checksum verification.
  Future<ContentReleaseEnvelope> load() async {
    final raw = await _loadString(starterAssetPath);
    return decodeContentReleaseEnvelope(raw);
  }
}
