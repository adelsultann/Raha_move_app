import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../../../app/theme/appearance_controller.dart';
import '../../onboarding/domain/app_language.dart';
import '../../reminders/presentation/reminder_settings_screen.dart';
import '../application/profile_controller.dart';
import 'profile_menu_widgets.dart';

class ProfileNotificationsScreen extends StatelessWidget {
  const ProfileNotificationsScreen({super.key, this.onReminders});
  final VoidCallback? onReminders;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.profileNotifications)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileMenuTile(
            tileKey: const Key('profile_reminders'),
            icon: Icons.schedule_outlined,
            title: s.reminderSettingsTitle,
            onTap:
                onReminders ??
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReminderSettingsScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class ProfileAppearanceScreen extends ConsumerWidget {
  const ProfileAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final selected =
        ref.watch(appearanceControllerProvider).value ?? AppAppearance.dark;
    return Scaffold(
      appBar: AppBar(title: Text(s.profileAppearance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioGroup<AppAppearance>(
            groupValue: selected,
            onChanged: (choice) async {
              if (choice == null) return;
              try {
                await ref
                    .read(appearanceControllerProvider.notifier)
                    .select(choice);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.profileSaveError)));
                }
              }
            },
            child: Column(
              children: [
                for (final appearance in AppAppearance.values)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioListTile<AppAppearance>(
                      key: Key('profile_appearance_${appearance.name}'),
                      title: Text(
                        appearance == AppAppearance.dark
                            ? s.profileAppearanceDark
                            : s.profileAppearanceNight,
                      ),
                      value: appearance,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLanguageScreen extends ConsumerWidget {
  const ProfileLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final settings = ref.watch(profileControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(s.profileLanguage)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioGroup<AppLanguage>(
            groupValue: settings?.language,
            onChanged: (choice) async {
              if (choice == null || choice == settings?.language) return;
              try {
                await ref
                    .read(profileControllerProvider.notifier)
                    .setLanguage(choice);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.profileSaveError)));
                }
              }
            },
            child: Column(
              children: [
                for (final language in AppLanguage.values)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioListTile<AppLanguage>(
                      key: Key('profile_language_${language.code}'),
                      title: Text(
                        language == AppLanguage.ar
                            ? s.languageArabic
                            : s.languageEnglish,
                      ),
                      value: language,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHealthSafetyScreen extends StatelessWidget {
  const ProfileHealthSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.profileHealthSafety)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          s.profileHelpBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
