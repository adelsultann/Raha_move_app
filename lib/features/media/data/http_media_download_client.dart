import 'dart:io';
import 'dart:typed_data';

import 'package:raha_move/features/media/domain/media_delivery.dart';

final class MediaDownloadException implements Exception {
  const MediaDownloadException(this.code);

  final String code;

  @override
  String toString() => 'MediaDownloadException($code)';
}

/// Downloads one short-lived capability without retaining or reporting it.
final class HttpMediaDownloadClient implements MediaDownloadClient {
  HttpMediaDownloadClient({
    HttpClient? client,
    DateTime Function()? clock,
    this.maximumBytes = 64 * 1024 * 1024,
  }) : _client = client ?? HttpClient(),
       _clock = clock ?? DateTime.now;

  final HttpClient _client;
  final DateTime Function() _clock;
  final int maximumBytes;

  void close() => _client.close(force: true);

  @override
  Future<Uint8List> download(EphemeralMediaUrl authorization) async {
    if (authorization.isExpiredAt(_clock().toUtc())) {
      throw const MediaDownloadException('authorization_expired');
    }
    try {
      final request = await _client.getUrl(authorization.value);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw const MediaDownloadException('http_rejected');
      }
      if (response.contentLength > maximumBytes) {
        await response.drain<void>();
        throw const MediaDownloadException('media_too_large');
      }
      final builder = BytesBuilder(copy: false);
      var total = 0;
      await for (final chunk in response) {
        total += chunk.length;
        if (total > maximumBytes) {
          throw const MediaDownloadException('media_too_large');
        }
        builder.add(chunk);
      }
      return builder.takeBytes();
    } on MediaDownloadException {
      rethrow;
    } catch (_) {
      throw const MediaDownloadException('transport_failed');
    }
  }
}
