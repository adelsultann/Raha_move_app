import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../../authentication/application/auth_controller.dart';
import '../application/profile_controller.dart';
import 'profile_account_section.dart';
import 'profile_menu_widgets.dart';
import 'profile_settings_pages.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.onSavedRoutines,
    required this.onHelp,
    required this.onPrivacy,
    this.onReminders,
  });

  final VoidCallback onSavedRoutines;
  final VoidCallback onHelp;
  final VoidCallback onPrivacy;
  final VoidCallback? onReminders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final settings = ref.watch(profileControllerProvider);
    final auth = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(s.profileTitle)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(profileControllerProvider),
            child: Text(s.retry),
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            ProfileSectionHeading(s.profileAccount),
            ProfileAccountSection(auth: auth),
            ProfileSectionHeading(s.profileSettings),
            ProfileMenuTile(
              tileKey: const Key('profile_notifications'),
              icon: Icons.notifications_outlined,
              title: s.profileNotifications,
              onTap: () => _open(
                context,
                ProfileNotificationsScreen(onReminders: onReminders),
              ),
            ),
            ProfileMenuTile(
              tileKey: const Key('profile_appearance'),
              icon: Icons.dark_mode_outlined,
              title: s.profileAppearance,
              onTap: () => _open(context, const ProfileAppearanceScreen()),
            ),
            ProfileMenuTile(
              tileKey: const Key('profile_language'),
              icon: Icons.language_outlined,
              title: s.profileLanguage,
              subtitle: value.language.code == 'ar'
                  ? s.languageArabic
                  : s.languageEnglish,
              onTap: () => _open(context, const ProfileLanguageScreen()),
            ),
            ProfileSectionHeading(s.profileSupport),
            ProfileMenuTile(
              tileKey: const Key('profile_saved_routines'),
              icon: Icons.bookmark_outline,
              title: s.savedRoutinesOpen,
              onTap: onSavedRoutines,
            ),
            ProfileMenuTile(
              tileKey: const Key('profile_help'),
              icon: Icons.help_outline,
              title: s.profileHelp,
              onTap: onHelp,
            ),
            ProfileMenuTile(
              tileKey: const Key('profile_privacy'),
              icon: Icons.privacy_tip_outlined,
              title: s.profilePrivacyPolicy,
              onTap: onPrivacy,
            ),
            ProfileMenuTile(
              tileKey: const Key('profile_health_safety'),
              icon: Icons.health_and_safety_outlined,
              title: s.profileHealthSafety,
              onTap: () => _open(context, const ProfileHealthSafetyScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
