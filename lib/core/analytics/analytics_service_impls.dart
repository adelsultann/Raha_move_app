import 'analytics_event.dart';
import 'analytics_service.dart';

/// A disabled analytics service that drops every event.
///
/// This is the default when the user has not opted in and the safe replacement
/// for tests and environments without an approved transport.
final class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  bool get isEnabled => false;

  @override
  void setEnabled(bool enabled) {}

  @override
  void track(AnalyticsEvent event) {}
}

/// A consent-gated, in-memory analytics service for debug and test use.
///
/// It sanitizes and records events locally so engineers can verify event names
/// and properties without sending anything to a production dataset.
final class InMemoryAnalyticsService implements AnalyticsService {
  InMemoryAnalyticsService({this.enabled = false, this.onEnabledChanged});

  final List<AnalyticsEvent> recordedEvents = <AnalyticsEvent>[];
  bool enabled;
  final void Function(bool enabled)? onEnabledChanged;

  @override
  bool get isEnabled => enabled;

  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
    onEnabledChanged?.call(enabled);
  }

  @override
  void track(AnalyticsEvent event) {
    if (!enabled) {
      return;
    }
    recordedEvents.add(sanitizeAnalyticsEvent(event));
  }

  void clear() => recordedEvents.clear();
}
