import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:raha_move/features/recommendations/domain/routine_readiness.dart';

/// Verifies media intentionally bundled with the application for the offline
/// starter experience. Bundled bytes never require a network authorization,
/// are not copied into the user media cache, and remain constrained to the
/// approved starter-media asset directory.
final class BundledRoutineMediaPreparer implements RoutineMediaPreparer {
  BundledRoutineMediaPreparer({AssetBundle? assets})
    : _assets = assets ?? rootBundle;

  static const _assetPrefix = 'asset:';
  static const _starterMediaPrefix = 'assets/starter_content/media/';

  final AssetBundle _assets;

  static bool supports(MediaDelivery media) {
    final path = _assetPathFor(media.deliveryReference);
    return path != null;
  }

  @override
  Future<RoutineMediaPreparation> prepareForStart(
    List<MediaDelivery> media, {
    required bool explicitUserStart,
  }) async {
    final results = <String, MediaPreparationResult>{};
    for (final item in media) {
      results[item.mediaId] = await _prepare(item);
    }
    return RoutineMediaPreparation(results);
  }

  Future<MediaPreparationResult> _prepare(MediaDelivery media) async {
    final path = _assetPathFor(media.deliveryReference);
    if (path == null) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.offline,
      );
    }
    try {
      final data = await _assets.load(path);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (sha256.convert(bytes).toString() !=
          media.checksumSha256.toLowerCase()) {
        return MediaUnavailable(
          mediaId: media.mediaId,
          code: MediaFailureCode.integrityMismatch,
        );
      }
      return MediaPrepared(
        mediaId: media.mediaId,
        localPath: path,
        fromCache: true,
      );
    } catch (_) {
      return MediaUnavailable(
        mediaId: media.mediaId,
        code: MediaFailureCode.cacheWriteFailed,
      );
    }
  }

  static String? _assetPathFor(String reference) {
    if (!reference.startsWith(_assetPrefix)) return null;
    final path = reference.substring(_assetPrefix.length);
    if (!path.startsWith(_starterMediaPrefix) ||
        path.contains('..') ||
        path.contains('\\')) {
      return null;
    }
    return path;
  }
}
