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
import 'package:raha_move/features/routine_player/domain/routine_playback_loader.dart';

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
  AppLanguage language = AppLanguage.en,
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
