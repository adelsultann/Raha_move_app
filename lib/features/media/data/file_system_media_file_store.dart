import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

/// Account-partitioned media files rooted in an application-owned cache
/// directory supplied by platform bootstrap code.
final class FileSystemMediaFileStore implements MediaFileStore {
  FileSystemMediaFileStore(this.rootDirectory);

  final Directory rootDirectory;
  final Random _random = Random.secure();

  @override
  Future<int?> availableBytes() async => null;

  @override
  Future<bool> exists(String path) => _safeFile(path).exists();

  @override
  Future<Uint8List> read(String path) async => _safeFile(path).readAsBytes();

  @override
  Future<String> writeTemporary(Uint8List bytes) async {
    final directory = Directory(_join(rootDirectory.path, '.temporary'));
    final path = _join(
      directory.path,
      '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}.part',
    );
    try {
      await directory.create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
      return path;
    } on FileSystemException catch (error) {
      if (_isOutOfSpace(error)) throw const MediaStorageException();
      rethrow;
    }
  }

  @override
  Future<void> commitTemporary({
    required String temporaryPath,
    required String path,
  }) async {
    final temporary = _safeFile(temporaryPath);
    final target = _safeFile(path);
    try {
      await target.parent.create(recursive: true);
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
    } on FileSystemException catch (error) {
      if (_isOutOfSpace(error)) throw const MediaStorageException();
      rethrow;
    }
  }

  @override
  Future<void> delete(String path) => _safeFile(path).delete();

  @override
  String pathFor({
    required String ownerId,
    required String mediaId,
    required String checksumSha256,
  }) {
    final owner = sha256.convert(utf8.encode(ownerId)).toString();
    final safeMediaId = mediaId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
    final safeChecksum = checksumSha256.toLowerCase().replaceAll(
      RegExp('[^a-f0-9]'),
      '',
    );
    return _join(
      _join(_join(rootDirectory.path, 'accounts'), owner),
      '$safeMediaId-$safeChecksum.media',
    );
  }

  File _safeFile(String path) {
    final root = rootDirectory.absolute.path;
    final candidate = File(path).absolute.path;
    final prefix = root.endsWith(Platform.pathSeparator)
        ? root
        : '$root${Platform.pathSeparator}';
    if (!candidate.startsWith(prefix)) {
      throw ArgumentError('Media cache path is outside the cache root');
    }
    return File(candidate);
  }

  static bool _isOutOfSpace(FileSystemException error) {
    final code = error.osError?.errorCode;
    if (code == 28 || code == 112) return true;
    final message = (error.osError?.message ?? '').toLowerCase();
    return message.contains('no space') ||
        message.contains('disk full') ||
        message.contains('not enough space');
  }

  static String _join(String first, String second) =>
      '$first${Platform.pathSeparator}$second';
}
