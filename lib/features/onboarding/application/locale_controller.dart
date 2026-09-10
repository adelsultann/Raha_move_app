import 'dart:ui' show Locale;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_catalog.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/telemetry/telemetry_providers.dart';
import '../../authentication/application/auth_controller.dart';
import '../../reminders/application/reminder_providers.dart';
import '../../reminders/domain/reminder_schedule.dart';
import '../../../app/localization/l10n/app_localizations_ar.dart';
import '../../../app/localization/l10n/app_localizations_en.dart';
import '../domain/app_language.dart';
import 'onboarding_providers.dart';

part 'locale_controller.g.dart';

/// The app-wide active [Locale], restored from the local profile at startup.
///
/// It is the single source of truth consumed by `RahaMoveApp` so choosing a
/// language immediately applies its directionality and localized strings.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<Locale> build() async {
    final auth = await ref.watch(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null) {
      throw StateError('LocaleController requires an active user id');
    }
    final language = await ref
        .read(onboardingRepositoryProvider)
        .readPreferredLanguage(userId);
    return Locale(language.code);
  }

  /// Applies [language] immediately (optimistic RTL/LTR switch), persists it
  /// local-first, and records a privacy-safe language-change event.
  Future<void> selectLanguage(AppLanguage language) async {
    state = AsyncData(Locale(language.code));

    final userId = ref.read(authControllerProvider).requireValue.activeUserId;
    if (userId == null) return;
    await ref
        .read(onboardingRepositoryProvider)
        .savePreferredLanguage(userId, language);
    // The persisted locale is the authoritative mutation point. Re-schedule
    // only an enabled existing reminder; this path never requests permission.
    await ref
        .read(reminderLifecycleServiceProvider)
        .reconcile(userId: userId, content: _reminderContent(language));

    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: AnalyticsEventName.languageChanged,
            properties: {AnalyticsPropertyKey.locale: language.code},
          ),
        );
  }

  ReminderNotificationContent _reminderContent(AppLanguage language) {
    final strings = switch (language) {
      AppLanguage.ar => AppLocalizationsAr(),
      AppLanguage.en => AppLocalizationsEn(),
    };
    return ReminderNotificationContent(
      title: strings.reminderNotificationTitle,
      body: strings.reminderNotificationBody,
    );
  }
}
