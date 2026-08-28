import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/logging/log_redactor.dart';

void main() {
  const redactor = LogRedactor();
  const redacted = LogRedactor.redacted;

  group('redact', () {
    test('redacts email addresses', () {
      expect(
        redactor.redact('contact adel@example.com now'),
        'contact $redacted now',
      );
    });

    test('redacts JSON web tokens', () {
      const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature';
      expect(redactor.redact('auth: $jwt'), 'auth: $redacted');
    });

    test('redacts bearer credentials and preserves the scheme', () {
      expect(
        redactor.redact('Authorization: Bearer abcDEF123._-xyz'),
        'Authorization: Bearer $redacted',
      );
    });

    test('redacts secret assignments and preserves the key name', () {
      expect(redactor.redact('api_key=sk_live_123'), 'api_key=$redacted');
      expect(redactor.redact('password: hunter2'), 'password=$redacted');
    });

    test('redacts signed URLs', () {
      const url =
          'https://cdn.example.com/video.mp4?X-Amz-Signature=abcd&X-Amz-Credential=xyz';
      expect(redactor.redact('load $url now'), 'load $redacted now');
    });

    test('redacts object-storage media URLs', () {
      const url = 'https://xyz.supabase.co/storage/v1/object/public/media.mp4';
      expect(redactor.redact('src=$url'), 'src=$redacted');
    });

    test('redacts phone numbers prefixed with a plus sign', () {
      expect(redactor.redact('call +966 555 123 4567'), 'call $redacted');
    });

    test('redacts long hex tokens', () {
      const token = '0123456789abcdef0123456789abcdef';
      expect(redactor.redact('checksum $token'), 'checksum $redacted');
    });

    test('leaves ordinary text untouched', () {
      const text = 'Routine started for the seated desk reset.';
      expect(redactor.redact(text), text);
    });
  });

  group('sanitizeFields', () {
    test('keeps only allowed keys', () {
      final result = redactor.sanitizeFields(
        <String, Object?>{'allowed': 'x', 'forbidden': 'y'},
        allowedKeys: const <String>{'allowed'},
      );
      expect(result, <String, Object?>{'allowed': 'x'});
    });

    test('redacts string values and keeps safe primitives', () {
      final result = redactor.sanitizeFields(
        <String, Object?>{
          'locale': 'en',
          'count': 3,
          'ok': true,
          'note': 'email adel@example.com',
          'nested': <String, Object?>{'a': 1},
        },
        allowedKeys: const <String>{'locale', 'count', 'ok', 'note', 'nested'},
      );
      expect(result['locale'], 'en');
      expect(result['count'], 3);
      expect(result['ok'], isTrue);
      expect(result['note'], 'email $redacted');
      expect(result['nested'], isNull);
    });
  });
}
