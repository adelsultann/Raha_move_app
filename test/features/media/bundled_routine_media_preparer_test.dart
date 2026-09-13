import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/media/application/bundled_routine_media_preparer.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

void main() {
  MediaDelivery delivery(String reference, List<int> bytes) => MediaDelivery(
    mediaId: 'starter-media',
    deliveryReference: reference,
    version: 'starter-1',
    checksumSha256: sha256.convert(bytes).toString(),
  );

  test(
    'verifies an approved bundled starter asset without network access',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final preparer = BundledRoutineMediaPreparer(
        assets: _AssetBundle({
          'assets/starter_content/media/videos/neck.gif': bytes,
        }),
      );
      final media = delivery(
        'asset:assets/starter_content/media/videos/neck.gif',
        bytes,
      );

      final result = await preparer.prepareForStart([
        media,
      ], explicitUserStart: true);

      expect(BundledRoutineMediaPreparer.supports(media), isTrue);
      expect(
        result.results[media.mediaId],
        isA<MediaPrepared>()
            .having((value) => value.fromCache, 'bundled', isTrue)
            .having(
              (value) => value.localPath,
              'asset path',
              'assets/starter_content/media/videos/neck.gif',
            ),
      );
    },
  );

  test(
    'rejects traversal and checksum-mismatched bundled references',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final preparer = BundledRoutineMediaPreparer(assets: _AssetBundle({}));
      final traversal = delivery(
        'asset:assets/starter_content/media/../secret',
        bytes,
      );
      final corrupt = delivery(
        'asset:assets/starter_content/media/videos/neck.gif',
        [9],
      );

      final traversalResult = await preparer.prepareForStart([
        traversal,
      ], explicitUserStart: true);
      final corruptResult = await BundledRoutineMediaPreparer(
        assets: _AssetBundle({
          'assets/starter_content/media/videos/neck.gif': bytes,
        }),
      ).prepareForStart([corrupt], explicitUserStart: true);

      expect(BundledRoutineMediaPreparer.supports(traversal), isFalse);
      expect(
        traversalResult.results[traversal.mediaId],
        isA<MediaUnavailable>().having(
          (value) => value.code,
          'code',
          MediaFailureCode.offline,
        ),
      );
      expect(
        corruptResult.results[corrupt.mediaId],
        isA<MediaUnavailable>().having(
          (value) => value.code,
          'code',
          MediaFailureCode.integrityMismatch,
        ),
      );
    },
  );
}

final class _AssetBundle extends CachingAssetBundle {
  _AssetBundle(this.assets);

  final Map<String, Uint8List> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw StateError('Missing test asset: $key');
    return ByteData.sublistView(bytes);
  }
}
