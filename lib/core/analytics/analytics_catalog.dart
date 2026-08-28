/// Stable, language-neutral analytics event identifiers.
///
/// These are the single source of truth for the event catalog defined in
/// RAHA-015. Feature code references these constants; it never invents event
/// names inline.
abstract final class AnalyticsEventName {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String checkInCompleted = 'check_in_completed';
  static const String recommendationShown = 'recommendation_shown';
  static const String recommendationAccepted = 'recommendation_accepted';
  static const String recommendationRejected = 'recommendation_rejected';
  static const String routineStarted = 'routine_started';
  static const String routineCompleted = 'routine_completed';
  static const String routineAbandoned = 'routine_abandoned';
  static const String feedbackSubmitted = 'feedback_submitted';
  static const String savedRoutineChanged = 'saved_routine_changed';
  static const String languageChanged = 'language_changed';
}

/// Approved categorical property keys. Values are limited to booleans, numbers,
/// stable Raha identifiers, and enumerated taxonomy keys.
abstract final class AnalyticsPropertyKey {
  /// `ar` or `en`.
  static const String locale = 'locale';

  /// Versioned recommendation engine configuration.
  static const String engineVersion = 'engine_version';

  static const String recommendationId = 'recommendation_id';
  static const String routineId = 'routine_id';
  static const String sessionId = 'session_id';

  /// `much_better`, `little_better`, `same`, or `less_comfortable`.
  static const String feedbackRating = 'feedback_rating';

  /// `too_easy`, `too_hard`, `position`, `discomfort`, or `other`.
  static const String rejectionReason = 'rejection_reason';

  /// `true` when the routine was saved, `false` when unsaved.
  static const String saved = 'saved';

  /// `recommendation`, `explore`, `saved`, `repeat`, or `bundled`.
  static const String source = 'source';
}

/// The implementation-enforced allowlist for analytics properties. Any key not
/// listed here is dropped before an event reaches a transport.
abstract final class AnalyticsPropertyAllowlist {
  static const Set<String> keys = <String>{
    AnalyticsPropertyKey.locale,
    AnalyticsPropertyKey.engineVersion,
    AnalyticsPropertyKey.recommendationId,
    AnalyticsPropertyKey.routineId,
    AnalyticsPropertyKey.sessionId,
    AnalyticsPropertyKey.feedbackRating,
    AnalyticsPropertyKey.rejectionReason,
    AnalyticsPropertyKey.saved,
    AnalyticsPropertyKey.source,
  };
}
