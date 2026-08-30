import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_catalog.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/telemetry/telemetry_providers.dart';
import '../../authentication/application/auth_controller.dart';
import 'onboarding_providers.dart';

part 'onboarding_controller.g.dart';

/// Whether the active user has completed onboarding. When false, the app shows
/// language selection and the onboarding pages; when true, it goes straight to
/// the app. Completion is persisted locally and never re-shown unless the data
/// is cleared or a fresh identity is created.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  Future<bool> build() async {
    final auth = await ref.watch(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) {
      throw StateError('OnboardingController requires an active user id');
    }
    return ref.read(onboardingRepositoryProvider).isOnboardingComplete(userId);
  }

  /// Marks onboarding complete for the active user and records a privacy-safe
  /// completion event. Completing as a guest is the only path; registration is
  /// never required.
  Future<void> complete() async {
    final userId = ref.read(authControllerProvider).requireValue.activeUserId;
    if (userId == null) return;
    await ref.read(onboardingRepositoryProvider).markOnboardingComplete(userId);
    state = AsyncData(true);

    ref
        .read(analyticsServiceProvider)
        .track(
          const AnalyticsEvent(name: AnalyticsEventName.onboardingCompleted),
        );
  }
}
