import 'package:flutter/material.dart';

import '../../../app/localization/l10n/app_localizations.dart';

enum ProfileInformationPage { help, privacy, terms }

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key, required this.page});
  final ProfileInformationPage page;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final (title, body) = switch (page) {
      ProfileInformationPage.help => (s.profileHelp, s.profileHelpBody),
      ProfileInformationPage.privacy => (
        s.profilePrivacyPolicy,
        s.profileLegalPending,
      ),
      ProfileInformationPage.terms => (s.profileTerms, s.profileLegalPending),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
