import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/logging/app_logger.dart';

void main() {
  const redacted = '<redacted>';

  group('PrivacySafeLogger', () {
    test('redacts message, error, and fields before the sink sees them', () {
      final sink = InMemoryLogSink();
      final logger = PrivacySafeLogger(sink: sink);

      logger.error(
        'Failed for adel@example.com with api_key=sk_live_123',
        Exception('token eyJhbGciOiJIUzI1NiJ9.signature leaked'),
        StackTrace.current,
        <String, Object?>{'session_id': 'abc-123', 'email': 'adel@example.com'},
      );

      expect(sink.entries, hasLength(1));
      final entry = sink.entries.single;
      expect(entry.level, LogLevel.error);
      expect(entry.message, 'Failed for $redacted with api_key=$redacted');
      expect(entry.error, 'Exception: token $redacted leaked');
      expect(entry.fields, containsPair('session_id', 'abc-123'));
      expect(entry.fields, isNot(contains('email')));
    });

    test('drops non-allowlisted structured field keys', () {
      final sink = InMemoryLogSink();
      final logger = PrivacySafeLogger(sink: sink);

      logger.info('msg', <String, Object?>{
        'routine_id': 'raha_r_1',
        'user_note': 'my back hurts',
        'email': 'a@b.com',
      });

      final fields = sink.entries.single.fields;
      expect(fields.keys, contains('routine_id'));
      expect(fields.keys, isNot(contains('user_note')));
      expect(fields.keys, isNot(contains('email')));
    });

    test('records a warning entry with sanitized fields', () {
      final sink = InMemoryLogSink();
      final logger = PrivacySafeLogger(sink: sink);

      logger.warning('offline retry pending', <String, Object?>{
        'retry_count': 3,
        'sync_state': 'failed',
      });

      final entry = sink.entries.single;
      expect(entry.level, LogLevel.warning);
      expect(entry.fields, containsPair('retry_count', 3));
      expect(entry.fields, containsPair('sync_state', 'failed'));
    });
  });

  group('sinks', () {
    test('noop sink drops everything', () {
      final logger = PrivacySafeLogger(sink: const NoopLogSink());
      logger.info('hello');
      // No exception or retention: nothing further to assert.
    });

    test('in-memory sink retains and can clear entries', () {
      final sink = InMemoryLogSink();
      final logger = PrivacySafeLogger(sink: sink);

      logger.debug('a');
      logger.info('b');
      expect(sink.entries, hasLength(2));

      sink.clear();
      expect(sink.entries, isEmpty);
    });
  });
}
