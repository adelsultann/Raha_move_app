import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/application/auth_controller.dart';
import '../../onboarding/application/locale_controller.dart';
import '../../onboarding/domain/app_language.dart';
import '../../../core/telemetry/telemetry_providers.dart';
import '../domain/profile_settings.dart';
import 'profile_providers.dart';

part 'profile_controller.g.dart';

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  @override
  Future<ProfileSettings> build() async {
    final user = await ref.watch(authControllerProvider.future);
    final settings = await ref
        .read(profileRepositoryProvider)
        .read(user.activeUserId!);
    // Restore both optional consents before feature events can be emitted.
    final consent = ref.read(telemetryConsentStoreProvider);
    await consent.setAnalytics(settings.analyticsEnabled);
    await consent.setCrashReporting(settings.crashReportingEnabled);
    return settings;
  }

  Future<void> saveSettings(ProfileSettings settings) async {
    final previous = state.requireValue;
    state = AsyncData(settings);
    try {
      final userId = ref
          .read(authControllerProvider)
          .requireValue
          .activeUserId!;
      await ref.read(profileRepositoryProvider).save(userId, settings);
      final consent = ref.read(telemetryConsentStoreProvider);
      await consent.setAnalytics(settings.analyticsEnabled);
      await consent.setCrashReporting(settings.crashReportingEnabled);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    await saveSettings(state.requireValue.copyWith(language: language));
    await ref.read(localeControllerProvider.notifier).selectLanguage(language);
  }
}
