import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/locale_controller.dart';
import '../domain/app_language.dart';

/// The first meaningful screen. Arabic and English are presented with equal
/// visual prominence and identical interaction weight; choosing one applies its
/// locale and direction before the user continues.
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key, required this.onLanguageSelected});

  /// Invoked after the language has been applied so the parent advances to the
  /// onboarding pages.
  final VoidCallback onLanguageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  strings.languageSelectionWelcomeArabic,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.languageSelectionWelcomeEnglish,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 48),
              _LanguageButton(
                key: const Key('language_arabic'),
                label: strings.languageArabic,
                onPressed: () => _select(ref, AppLanguage.ar),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                key: const Key('language_english'),
                label: strings.languageEnglish,
                onPressed: () => _select(ref, AppLanguage.en),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _select(WidgetRef ref, AppLanguage language) async {
    await ref.read(localeControllerProvider.notifier).selectLanguage(language);
    onLanguageSelected();
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
