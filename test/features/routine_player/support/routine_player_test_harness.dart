import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/telemetry/telemetry_providers.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/media/application/media_providers.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:raha_move/features/onboarding/application/onboarding_providers.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/routine_player/application/routine_player_controller.dart';
import 'package:raha_move/features/routine_player/application/routine_player_providers.dart';
import 'package:raha_move/features/routine_player/application/routine_player_state.dart';
import 'package:raha_move/features/routine_player/domain/playback_plan.dart';
import 'package:raha_move/features/routine_player/domain/playback_session.dart';
import 'package:raha_move/features/routine_player/domain/playback_support.dart';
import 'package:raha_move/features/routine_player/domain/playback_ticker.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback.dart';
import 'package:raha_move/features/routine_player/domain/routine_feedback_repository.dart';
import 'package:raha_move/features/routine_player/domain/routine_playback_loader.dart';
import 'package:raha_move/features/routine_player/domain/routine_session_repository.dart';

import '../../onboarding/support/onboarding_test_harness.dart'
    show FakeAuthRepository, FakeGuestIdentityStore, FakeOnboardingRepository;

const _checksum =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

MediaDelivery _delivery(String id) => MediaDelivery(
  mediaId: id,
  deliveryReference: 'ref-$id',
  version: 'v1',
  checksumSha256: _checksum,
);

/// A fixed two-step plan for playback tests, localized so widget tests can run
/// in both English and Arabic.
RoutinePlaybackPlan twoStepPlan({String locale = 'en'}) {
  final isArabic = locale == 'ar';
  return RoutinePlaybackPlan(
    routineId: 'rt-1',
    routineVersion: 1,
    routineName: isArabic ? 'روتين تجريبي' : 'Test Routine',
    steps: [
      RoutineStepPlan(
        stepId: 'step-1',
        exerciseId: 'ex-1',
        name: isArabic ? 'تحرير الرقبة' : 'Neck release',
        shortCue: isArabic ? 'تنفّس بارتياح' : 'Breathe comfortably',
        durationSeconds: 3,
        media: _delivery('media-1'),
      ),
      RoutineStepPlan(
        stepId: 'step-2',
        exerciseId: 'ex-2',
        name: isArabic ? 'دوائر الكتف' : 'Shoulder circles',
        shortCue: null,
        durationSeconds: 5,
        media: _delivery('media-2'),
      ),
    ],
  );
}

/// A two-step, one-minute-total plan so completion summaries render a non-zero
/// verified-active-minute figure in widget tests. Two steps keep the last-step
/// "Finish" control out of the initial frame, which avoids an unrelated
/// RAHA-051 player-control overflow at 200% text scale.
RoutinePlaybackPlan minutePlan({String locale = 'en'}) {
  final isArabic = locale == 'ar';
  return RoutinePlaybackPlan(
    routineId: 'rt-1',
    routineVersion: 1,
    routineName: isArabic ? 'روتين تجريبي' : 'Test Routine',
    steps: [
      RoutineStepPlan(
        stepId: 'step-1',
        exerciseId: 'ex-1',
        name: isArabic ? 'تحرير الرقبة' : 'Neck release',
        shortCue: null,
        durationSeconds: 30,
        media: _delivery('media-1'),
      ),
      RoutineStepPlan(
        stepId: 'step-2',
        exerciseId: 'ex-2',
        name: isArabic ? 'دوائر الكتف' : 'Shoulder circles',
        shortCue: null,
        durationSeconds: 30,
        media: _delivery('media-2'),
      ),
    ],
  );
}

/// Loader fake returning a locale-aware plan.
final class FakeRoutinePlaybackLoader implements RoutinePlaybackLoader {
  FakeRoutinePlaybackLoader(this.build);

  final RoutinePlaybackPlan Function(String locale) build;

  @override
  Future<RoutinePlaybackPlan> load(String routineId, String locale) async =>
      build(locale);
}

/// Ticker fake that tests drive deterministically.
final class FakePlaybackTicker implements PlaybackTicker {
  void Function()? onTick;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  void start(void Function() onTick) {
    this.onTick = onTick;
    startCalls++;
  }

  @override
  void stop() {
    onTick = null;
    stopCalls++;
  }

  void fireTick() => onTick?.call();

  bool get isRunning => onTick != null;
}

/// Wake-lock fake recording enable/disable calls.
final class FakeScreenWakeLock implements ScreenWakeLock {
  int enableCalls = 0;
  int disableCalls = 0;

  @override
  Future<void> enable() async {
    enableCalls++;
  }

  @override
  Future<void> disable() async {
    disableCalls++;
  }
}

/// Transition-feedback fake recording transition calls.
final class FakeTransitionFeedback implements TransitionFeedback {
  int transitionCalls = 0;

  @override
  void onStepTransition() {
    transitionCalls++;
  }
}

/// A captured [RoutineSessionRepository.save] call, for asserting persistence.
final class SessionSaveCall {
  const SessionSaveCall({
    required this.userId,
    required this.sessionId,
    required this.routineId,
    required this.routineVersion,
    this.recommendationId,
    required this.startedAt,
    required this.steps,
    this.currentStepPosition,
    this.currentStepActiveSeconds,
    required this.explicitlyAbandoned,
  });

  final String userId;
  final String sessionId;
  final String routineId;
  final int routineVersion;
  final String? recommendationId;
  final DateTime startedAt;
  final List<RoutineStepSnapshot> steps;
  final int? currentStepPosition;
  final int? currentStepActiveSeconds;
  final bool explicitlyAbandoned;
}

/// A captured [RoutineSessionRepository.saveCursor] call.
final class CursorSaveCall {
  const CursorSaveCall({
    required this.sessionId,
    required this.position,
    required this.seconds,
  });

  final String sessionId;
  final int position;
  final int seconds;
}

/// In-memory [RoutineSessionRepository] that records writes and returns
/// configured snapshots for resume/restore. Keeps controller tests free of
/// Drift.
final class FakeRoutineSessionRepository implements RoutineSessionRepository {
  final List<SessionSaveCall> saves = [];
  final List<CursorSaveCall> cursors = [];
  RoutineSessionSnapshot? resumableResult;
  RoutineSessionSnapshot? findByIdResult;
  String? lastUserId;

  /// Records method invocation order so tests can assert expiration precedes
  /// any resumable/restore lookup.
  final List<String> callLog = [];

  /// When true, [save] throws, simulating an authoritative write failure.
  bool failSave = false;

  /// When true, [saveCursor] throws, simulating a local-only cursor failure.
  bool failCursor = false;

  int expireCalls = 0;

  @override
  Future<void> save({
    required String userId,
    required String sessionId,
    required String routineId,
    required int routineVersion,
    String? recommendationId,
    required DateTime startedAt,
    required List<RoutineStepSnapshot> steps,
    int? currentStepPosition,
    int? currentStepActiveSeconds,
    bool explicitlyAbandoned = false,
  }) async {
    callLog.add('save');
    lastUserId = userId;
    if (failSave) throw StateError('save failed');
    saves.add(
      SessionSaveCall(
        userId: userId,
        sessionId: sessionId,
        routineId: routineId,
        routineVersion: routineVersion,
        recommendationId: recommendationId,
        startedAt: startedAt,
        steps: steps,
        currentStepPosition: currentStepPosition,
        currentStepActiveSeconds: currentStepActiveSeconds,
        explicitlyAbandoned: explicitlyAbandoned,
      ),
    );
  }

  @override
  Future<void> saveCursor({
    required String userId,
    required String sessionId,
    required int currentStepPosition,
    required int activeSeconds,
  }) async {
    callLog.add('saveCursor');
    lastUserId = userId;
    if (failCursor) throw StateError('cursor failed');
    cursors.add(
      CursorSaveCall(
        sessionId: sessionId,
        position: currentStepPosition,
        seconds: activeSeconds,
      ),
    );
  }

  @override
  Future<RoutineSessionSnapshot?> resumable({required String userId}) async {
    callLog.add('resumable');
    return resumableResult;
  }

  @override
  Future<RoutineSessionSnapshot?> findById({
    required String userId,
    required String sessionId,
  }) async {
    callLog.add('findById');
    return findByIdResult;
  }

  @override
  Future<void> expireInactiveSessions({required String userId}) async {
    callLog.add('expire');
    expireCalls++;
  }
}

/// In-memory [RoutineFeedbackRepository] that records writes so controller
/// tests can assert persistence and failure/retry without Drift. `save` mirrors
/// the real non-overwrite contract and returns false once a session has a
/// response.
final class FakeRoutineFeedbackRepository implements RoutineFeedbackRepository {
  final List<({String userId, String sessionId, FeedbackRating rating})> saves =
      [];

  /// When true, [save] throws, simulating a local write failure.
  bool failSave = false;

  /// A pre-existing stored rating to return from [find] for any session,
  /// simulating a response already persisted on a previous run.
  FeedbackRating? findResult;

  @override
  Future<bool> save({
    required String userId,
    required String sessionId,
    required FeedbackRating rating,
  }) async {
    if (failSave) throw StateError('feedback save failed');
    if (saves.any((s) => s.sessionId == sessionId)) return false;
    saves.add((userId: userId, sessionId: sessionId, rating: rating));
    return true;
  }

  @override
  Future<FeedbackRating?> find({
    required String userId,
    required String sessionId,
  }) async {
    if (findResult != null) return findResult;
    for (final saved in saves) {
      if (saved.sessionId == sessionId) return saved.rating;
    }
    return null;
  }
}

/// Builds a container wired with the fakes the player controller needs: an
/// Builds a container wired with the fakes the player controller needs: offline
/// auth, a locale-aware loader, deterministic ticker/wake-lock/feedback fakes,
/// and an enabled in-memory analytics sink. The Drift database is deliberately
/// not wired because the loader, feedback, wake lock, and ticker are all faked,
/// so the controller never reaches the local content cache.
ProviderContainer buildRoutinePlayerContainer({
  RoutinePlaybackPlan Function(String locale)? planForLocale,
  FakePlaybackTicker? ticker,
  FakeScreenWakeLock? wakeLock,
  FakeTransitionFeedback? feedback,
  InMemoryAnalyticsService? analytics,
  FakeRoutineSessionRepository? repository,
  FakeRoutineFeedbackRepository? feedbackRepository,
  AppLanguage language = AppLanguage.en,
  DateTime Function()? clock,
}) {
  return ProviderContainer(
    overrides: [
      appVersionProvider.overrideWithValue('1.0.0'),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      guestIdentityStoreProvider.overrideWithValue(FakeGuestIdentityStore()),
      onboardingRepositoryProvider.overrideWithValue(
        FakeOnboardingRepository()..language = language,
      ),
      routinePlaybackLoaderProvider.overrideWithValue(
        FakeRoutinePlaybackLoader(
          planForLocale ?? (locale) => twoStepPlan(locale: locale),
        ),
      ),
      playbackTickerProvider.overrideWithValue(ticker ?? FakePlaybackTicker()),
      screenWakeLockProvider.overrideWithValue(
        wakeLock ?? FakeScreenWakeLock(),
      ),
      transitionFeedbackProvider.overrideWithValue(
        feedback ?? FakeTransitionFeedback(),
      ),
      analyticsServiceProvider.overrideWithValue(
        analytics ?? InMemoryAnalyticsService(enabled: true),
      ),
      routineMediaPlaybackCoordinatorProvider.overrideWith((ref) async => null),
      routineSessionRepositoryProvider.overrideWithValue(
        repository ?? FakeRoutineSessionRepository(),
      ),
      routineFeedbackRepositoryProvider.overrideWithValue(
        feedbackRepository ?? FakeRoutineFeedbackRepository(),
      ),
      routinePlayerClockProvider.overrideWithValue(
        clock ?? () => DateTime.utc(2026, 8, 29, 12),
      ),
    ],
  );
}

/// Reads the current ready session from a container that has a live listener.
RoutinePlaybackSession readySession(
  ProviderContainer container,
  RoutinePlayerArgs args,
) {
  final state = container.read(routinePlayerControllerProvider(args));
  return (state as RoutinePlayerReady).session;
}
