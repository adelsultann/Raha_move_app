import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/crash_reporting/crash_reporter_impls.dart';

void main() {
  final stack = StackTrace.current;

  group('NoopCrashReporter', () {
    test('is disabled and drops reports', () {
      const reporter = NoopCrashReporter();
      expect(reporter.isEnabled, isFalse);
      reporter.recordError('boom', stack);
    });
  });

  group('InMemoryCrashReporter', () {
    test('drops reports while disabled', () {
      final reporter = InMemoryCrashReporter();
      reporter.recordError('boom', stack);
      expect(reporter.recordedReports, isEmpty);
    });

    test('records redacted reports when enabled', () {
      final reporter = InMemoryCrashReporter()..setEnabled(true);
      reporter.recordError(
        'failed token eyJhbGciOiJIUzI1NiJ9.signature for adel@example.com',
        stack,
        context: <String, Object?>{
          'session_id': 'sess-1',
          'locale': 'en',
          'password': 'hunter2',
        },
      );

      expect(reporter.recordedReports, hasLength(1));
      final report = reporter.recordedReports.single;
      expect(report.error, contains('<redacted>'));
      expect(report.error, isNot(contains('eyJ')));
      expect(report.error, isNot(contains('adel@example.com')));
      expect(report.context, containsPair('session_id', 'sess-1'));
      expect(report.context, containsPair('locale', 'en'));
      expect(report.context, isNot(contains('password')));
    });

    test('drops non-allowlisted context keys and nested objects', () {
      final reporter = InMemoryCrashReporter()..setEnabled(true);
      reporter.recordError(
        'boom',
        stack,
        context: <String, Object?>{
          'app_version': '1.0.0',
          'user_id': 'user-123',
          'credentials': <String, Object?>{'token': 'x'},
        },
      );

      final context = reporter.recordedReports.single.context;
      expect(context.keys, contains('app_version'));
      expect(context.keys, isNot(contains('user_id')));
      expect(context.keys, isNot(contains('credentials')));
    });
  });
}
