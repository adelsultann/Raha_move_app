import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/analytics/analytics_service.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';

void main() {
  const routineEvent = AnalyticsEvent(
    name: AnalyticsEventName.routineStarted,
    properties: <String, Object?>{
      AnalyticsPropertyKey.routineId: 'raha_r_1',
      AnalyticsPropertyKey.sessionId: 'sess-1',
    },
  );

  group('NoopAnalyticsService', () {
    test('is disabled and cannot be enabled', () {
      const service = NoopAnalyticsService();
      expect(service.isEnabled, isFalse);
      service.setEnabled(true);
      expect(service.isEnabled, isFalse);
    });

    test('drops events', () {
      const service = NoopAnalyticsService();
      service.track(routineEvent);
    });
  });

  group('InMemoryAnalyticsService', () {
    test('drops events while disabled', () {
      final service = InMemoryAnalyticsService();
      expect(service.isEnabled, isFalse);
      service.track(routineEvent);
      expect(service.recordedEvents, isEmpty);
    });

    test('records sanitized events when enabled', () {
      final service = InMemoryAnalyticsService()..setEnabled(true);
      service.track(routineEvent);

      expect(service.recordedEvents, hasLength(1));
      expect(
        service.recordedEvents.single.name,
        AnalyticsEventName.routineStarted,
      );
      expect(service.recordedEvents.single.properties, <String, Object?>{
        AnalyticsPropertyKey.routineId: 'raha_r_1',
        AnalyticsPropertyKey.sessionId: 'sess-1',
      });
    });

    test('sanitizer drops non-allowlisted keys and nested objects', () {
      final service = InMemoryAnalyticsService()..setEnabled(true);
      service.track(
        const AnalyticsEvent(
          name: AnalyticsEventName.languageChanged,
          properties: <String, Object?>{
            AnalyticsPropertyKey.locale: 'ar',
            'email': 'adel@example.com',
            'signed_url': 'https://x.com/a.mp4?X-Amz-Signature=abc',
            'nested': <String, Object?>{'a': 1},
          },
        ),
      );

      final properties = service.recordedEvents.single.properties;
      expect(properties.keys, contains(AnalyticsPropertyKey.locale));
      expect(properties.keys, isNot(contains('email')));
      expect(properties.keys, isNot(contains('signed_url')));
      expect(properties.keys, isNot(contains('nested')));
    });

    test('notifies the consent callback when enabled state changes', () {
      bool? changed;
      final service = InMemoryAnalyticsService(
        onEnabledChanged: (v) => changed = v,
      );
      service.setEnabled(true);
      expect(changed, isTrue);
    });
  });

  group('event catalog', () {
    test('covers every RAHA-015 event with stable language-neutral names', () {
      const names = <String>{
        AnalyticsEventName.onboardingCompleted,
        AnalyticsEventName.checkInCompleted,
        AnalyticsEventName.recommendationShown,
        AnalyticsEventName.recommendationAccepted,
        AnalyticsEventName.recommendationRejected,
        AnalyticsEventName.routineStarted,
        AnalyticsEventName.routineCompleted,
        AnalyticsEventName.routineAbandoned,
        AnalyticsEventName.feedbackSubmitted,
        AnalyticsEventName.savedRoutineChanged,
        AnalyticsEventName.languageChanged,
      };

      expect(names, hasLength(11));
      final validName = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final name in names) {
        expect(validName.hasMatch(name), isTrue, reason: name);
      }
    });

    test('sanitizeAnalyticsEvent enforces the allowlist', () {
      final sanitized = sanitizeAnalyticsEvent(
        const AnalyticsEvent(
          name: AnalyticsEventName.feedbackSubmitted,
          properties: <String, Object?>{
            AnalyticsPropertyKey.feedbackRating: 'little_better',
            'free_text_note': 'my neck hurts',
          },
        ),
      );

      expect(sanitized.properties, <String, Object?>{
        AnalyticsPropertyKey.feedbackRating: 'little_better',
      });
    });
  });
}
