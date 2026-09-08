import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../../../app/router/app_routes.dart';
import '../../authentication/application/auth_controller.dart';
import '../../authentication/domain/auth_state.dart';
import '../../onboarding/application/locale_controller.dart';
import '../../onboarding/domain/app_language.dart';
import '../../preferences/domain/experience_level.dart';
import '../application/profile_controller.dart';
import '../application/profile_providers.dart';
import '../domain/account_deletion_action.dart';
import '../domain/profile_settings.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.onSavedRoutines,
    required this.onHelp,
    required this.onPrivacy,
    required this.onTerms,
  });
  final VoidCallback onSavedRoutines;
  final VoidCallback onHelp;
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final settings = ref.watch(profileControllerProvider);
    final auth = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.profileTitle)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(profileControllerProvider),
            child: Text(strings.retry),
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Heading(strings.profilePreferences),
            _LanguageTile(settings: value),
            _ExperienceTile(settings: value),
            _GoalTile(settings: value),
            _PositionsTile(settings: value),
            _SwitchTile(
              key: const Key('profile_sound'),
              label: strings.profileSound,
              value: value.soundEnabled,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(soundEnabled: enabled),
              ),
            ),
            _SwitchTile(
              key: const Key('profile_vibration'),
              label: strings.profileVibration,
              value: value.vibrationEnabled,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(vibrationEnabled: enabled),
              ),
            ),
            _SwitchTile(
              key: const Key('profile_wifi_downloads'),
              label: strings.profileWifiOnly,
              subtitle: strings.profileWifiOnlyHint,
              value: value.wifiOnlyDownloads,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(wifiOnlyDownloads: enabled),
              ),
            ),
            _SwitchTile(
              key: const Key('profile_reminder_interest'),
              label: strings.profileReminderInterest,
              subtitle: strings.profileReminderInterestHint,
              value: value.reminderInterest,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(reminderInterest: enabled),
              ),
            ),
            _Heading(strings.profilePrivacy),
            _SwitchTile(
              key: const Key('profile_analytics'),
              label: strings.profileAnalytics,
              subtitle: strings.profileAnalyticsHint,
              value: value.analyticsEnabled,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(analyticsEnabled: enabled),
              ),
            ),
            _SwitchTile(
              key: const Key('profile_crash_reporting'),
              label: strings.profileCrashReporting,
              subtitle: strings.profileCrashReportingHint,
              value: value.crashReportingEnabled,
              onChanged: (enabled) => saveProfileSettings(
                context,
                ref,
                value.copyWith(crashReportingEnabled: enabled),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: Text(strings.profileAccessibility),
              subtitle: Text(strings.profileDeviceTextSize),
            ),
            _Heading(strings.profileSupport),
            ListTile(
              key: const Key('profile_saved_routines'),
              leading: const Icon(Icons.bookmark_outline),
              title: Text(strings.savedRoutinesOpen),
              onTap: onSavedRoutines,
            ),
            ListTile(
              key: const Key('profile_help'),
              leading: const Icon(Icons.help_outline),
              title: Text(strings.profileHelp),
              onTap: onHelp,
            ),
            ListTile(
              key: const Key('profile_privacy'),
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(strings.profilePrivacyPolicy),
              onTap: onPrivacy,
            ),
            ListTile(
              key: const Key('profile_terms'),
              leading: const Icon(Icons.description_outlined),
              title: Text(strings.profileTerms),
              onTap: onTerms,
            ),
            _Heading(strings.profileAccount),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_accountLabel(strings, auth)),
              subtitle: Text(_accountDetail(strings, auth)),
            ),
            if (auth?.status == AuthStatus.authenticated)
              ListTile(
                key: const Key('profile_sign_out'),
                leading: const Icon(Icons.logout),
                title: Text(strings.signOut),
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ListTile(
              key: const Key('profile_delete_account'),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                strings.profileDeleteAccount,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: auth == null
                  ? null
                  : () => _confirmDeletion(
                      context,
                      ref,
                      auth.status == AuthStatus.authenticated,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _accountLabel(AppLocalizations s, AuthState? auth) =>
      auth?.status == AuthStatus.authenticated
      ? s.profileRegisteredAccount
      : s.profileGuestAccount;
  String _accountDetail(AppLocalizations s, AuthState? auth) =>
      auth?.status == AuthStatus.authenticated
      ? s.profileRegisteredAccountHint
      : s.profileGuestAccountHint;

  Future<void> _confirmDeletion(
    BuildContext context,
    WidgetRef ref,
    bool registered,
  ) async {
    final s = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.profileDeleteConfirmTitle),
        content: Text(
          registered ? s.profileDeleteRegisteredBody : s.profileDeleteGuestBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            key: const Key('profile_confirm_delete'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.profileDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(accountDeletionActionProvider)
        .requestDeletion(isRegisteredAccount: registered);
    if (!context.mounted) return;
    if (result == AccountDeletionResult.accepted) {
      // The cleanup created a fresh local guest identity after removing the old
      // account. Rebuild app-owned state from that identity rather than leaving
      // a stale authenticated snapshot visible.
      ref.invalidate(authControllerProvider);
      ref.invalidate(profileControllerProvider);
    }
    if (result == AccountDeletionResult.acceptedWithPendingCleanup) {
      // The server has accepted the deletion. Immediately move the root gate
      // into its privacy boundary; it retries only the durable local cleanup.
      ref.invalidate(accountDeletionRecoveryProvider);
    }
    final message = switch (result) {
      AccountDeletionResult.accepted => s.profileDeleteAccepted,
      AccountDeletionResult.acceptedWithPendingCleanup =>
        s.profileDeleteAcceptedCleanupPending,
      AccountDeletionResult.requiresRecentSignIn =>
        s.profileDeleteRequiresSignIn,
      AccountDeletionResult.unavailable => s.profileDeleteUnavailable,
      AccountDeletionResult.failed => s.profileDeleteFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: result == AccountDeletionResult.requiresRecentSignIn
            ? SnackBarAction(
                label: s.signInButton,
                onPressed: () => const SignInRoute().push(context),
              )
            : null,
      ),
    );
  }
}

Future<void> saveProfileSettings(
  BuildContext context,
  WidgetRef ref,
  ProfileSettings settings,
) async {
  try {
    await ref.read(profileControllerProvider.notifier).saveSettings(settings);
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).profileSaveError),
          action: SnackBarAction(
            key: const Key('profile_save_retry'),
            label: AppLocalizations.of(context).retry,
            onPressed: () => saveProfileSettings(context, ref, settings),
          ),
        ),
      );
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 20, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    key: key,
    title: Text(label),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
  );
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.settings});
  final ProfileSettings settings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    return ListTile(
      key: const Key('profile_language'),
      title: Text(s.profileLanguage),
      subtitle: Text(
        settings.language == AppLanguage.ar
            ? s.languageArabic
            : s.languageEnglish,
      ),
      trailing: DropdownButton<AppLanguage>(
        value: settings.language,
        onChanged: (v) {
          if (v != null) {
            saveProfileSettings(context, ref, settings.copyWith(language: v));
            ref.read(localeControllerProvider.notifier).selectLanguage(v);
          }
        },
        items: [
          DropdownMenuItem(
            value: AppLanguage.ar,
            child: Text(s.languageArabic),
          ),
          DropdownMenuItem(
            value: AppLanguage.en,
            child: Text(s.languageEnglish),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({required this.settings});
  final ProfileSettings settings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    return ListTile(
      key: const Key('profile_weekly_goal'),
      title: Text(s.profileWeeklyGoal),
      subtitle: Text(s.profileDaysPerWeek(settings.weeklyGoalDays)),
      trailing: DropdownButton<int>(
        value: settings.weeklyGoalDays,
        onChanged: (v) {
          if (v != null) {
            saveProfileSettings(
              context,
              ref,
              settings.copyWith(weeklyGoalDays: v),
            );
          }
        },
        items: [
          for (var i = 1; i <= 7; i++)
            DropdownMenuItem(value: i, child: Text('$i')),
        ],
      ),
    );
  }
}

class _ExperienceTile extends ConsumerWidget {
  const _ExperienceTile({required this.settings});

  final ProfileSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    String labelFor(ExperienceLevel level) => switch (level) {
      ExperienceLevel.beginner => strings.preferencesExperienceBeginner,
      ExperienceLevel.intermediate => strings.preferencesExperienceIntermediate,
      ExperienceLevel.advanced => strings.preferencesExperienceAdvanced,
    };
    return ListTile(
      key: const Key('profile_movement_experience'),
      title: Text(strings.profileMovementExperience),
      subtitle: Text(labelFor(settings.experienceLevel)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final level in ExperienceLevel.values)
                ListTile(
                  key: Key('profile_movement_experience_${level.code}'),
                  title: Text(labelFor(level)),
                  trailing: level == settings.experienceLevel
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    saveProfileSettings(
                      context,
                      ref,
                      settings.copyWith(experienceLevel: level),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionsTile extends ConsumerWidget {
  const _PositionsTile({required this.settings});
  final ProfileSettings settings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final labels = {
      'seated': s.preferencesPositionSeated,
      'standing': s.preferencesPositionStanding,
      'floor': s.preferencesPositionFloor,
    };
    return ExpansionTile(
      key: const Key('profile_positions'),
      title: Text(s.profileMovementPositions),
      subtitle: Text(
        settings.permittedPositions.isEmpty
            ? s.profileAnyPosition
            : settings.permittedPositions.map((p) => labels[p]).join(', '),
      ),
      children: [
        for (final entry in labels.entries)
          CheckboxListTile(
            value: settings.permittedPositions.contains(entry.key),
            title: Text(entry.value),
            onChanged: (selected) {
              final next = {...settings.permittedPositions};
              selected == true ? next.add(entry.key) : next.remove(entry.key);
              saveProfileSettings(
                context,
                ref,
                settings.copyWith(permittedPositions: next),
              );
            },
          ),
      ],
    );
  }
}
