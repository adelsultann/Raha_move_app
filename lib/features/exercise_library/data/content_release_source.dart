import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'canonical_json.dart';
import 'content_release_contract.dart';

/// Injectable source of the next compatible catalog release.
///
/// There is intentionally no concrete Supabase-backed implementation in this
/// repository while the Supabase dependency is absent. A production
/// implementation calls `get_next_content_release(current_release_id,
/// app_version)` and feeds the returned `manifest_checksum` plus `manifest`
/// into [buildContentReleaseEnvelope]. Tests inject fakes.
abstract interface class ContentReleaseSource {
  /// Returns the next release strictly after [currentReleaseId], or `null` when
  /// the client is already up to date. Implementations must return a payload
  /// that passes [buildContentReleaseEnvelope]'s checksum verification.
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  });
}

/// The default offline source used while no live catalog backend is configured.
/// It always reports "no release available", so bootstrap applies the bundled
/// starter catalog and the app runs entirely from local content. Replace this
/// with a real source (via provider override) once a backend is available.
final class NoopContentReleaseSource implements ContentReleaseSource {
  const NoopContentReleaseSource();

  @override
  Future<ContentReleaseEnvelope?> fetchNextRelease({
    required String currentReleaseId,
    required String appVersion,
  }) async => null;
}

/// Lower-case hex SHA-256 of canonical UTF-8 bytes.
String canonicalManifestChecksum(List<int> canonicalBytes) =>
    sha256.convert(canonicalBytes).toString();

/// Builds a typed [ContentReleaseEnvelope] from a decoded wire payload of the
/// form `{"manifest_checksum": "<hex>", "manifest": {...}}`.
///
/// The checksum is verified against the canonical UTF-8 JSON bytes of the
/// manifest before the envelope is returned, so callers can trust that the
/// bytes and the checksum agree. The envelope's release metadata is read from
/// the manifest's `release` object so the checksum covers every field used.
ContentReleaseEnvelope buildContentReleaseEnvelope(Map<String, dynamic> wire) {
  final checksum = wire['manifest_checksum'];
  if (checksum is! String || checksum.trim().isEmpty) {
    throw const ContentReleaseException(
      'invalid_release',
      'Missing manifest checksum',
    );
  }
  final manifestValue = wire['manifest'];
  if (manifestValue is! Map) {
    throw const ContentReleaseException('invalid_release', 'Missing manifest');
  }
  final manifestMap = Map<String, dynamic>.from(manifestValue);
  final canonicalBytes = CanonicalJson.encodeBytes(manifestMap);
  final normalized = checksum.trim().toLowerCase();
  final computed = canonicalManifestChecksum(canonicalBytes);
  if (computed != normalized) {
    throw const ContentReleaseException(
      'checksum_mismatch',
      'Canonical manifest checksum does not match the provided value',
    );
  }
  final manifest = ContentReleaseManifest.fromJson(manifestMap);
  return ContentReleaseEnvelope(
    releaseId: manifest.release.id,
    version: manifest.release.version,
    minimumAppVersion: manifest.release.minimumAppVersion,
    publishedAt: manifest.release.publishedAt,
    manifestChecksum: normalized,
    canonicalManifestBytes: Uint8List.fromList(canonicalBytes),
    manifest: manifest,
  );
}

/// Decodes a wire JSON string (the shape accepted by
/// [buildContentReleaseEnvelope]) into a verified envelope.
ContentReleaseEnvelope decodeContentReleaseEnvelope(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const ContentReleaseException(
      'invalid_release',
      'Payload is not JSON',
    );
  }
  if (decoded is! Map) {
    throw const ContentReleaseException(
      'invalid_release',
      'Payload is not an object',
    );
  }
  return buildContentReleaseEnvelope(Map<String, dynamic>.from(decoded));
}
