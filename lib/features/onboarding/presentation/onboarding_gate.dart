import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/locale_controller.dart';
import '../application/onboarding_controller.dart';
import '../../preferences/presentation/preferences_screen.dart';
import 'language_selection_screen.dart';
import 'onboarding_screen.dart';

/// Gates the app on onboarding completion.
///
/// A new user sees language selection followed by the onboarding pages; a user
/// who has already completed onboarding is sent straight to [child]. This
/// mirrors the existing `AuthGate`/`CatalogBootstrapGate` pattern and renders
/// its own localized `MaterialApp` until onboarding is done.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    final resolvedLocale = locale.value;

    if (onboarding.isLoading || locale.isLoading) {
      return _gate(locale: resolvedLocale, body: const _OnboardingLoading());
    }
    if (onboarding.hasError || locale.hasError) {
      return _gate(
        locale: resolvedLocale,
        body: _OnboardingError(
          onRetry: () {
            ref.invalidate(onboardingControllerProvider);
            ref.invalidate(localeControllerProvider);
          },
        ),
      );
    }
    if (onboarding.value == false) {
      return _gate(locale: resolvedLocale, body: const _OnboardingFlow());
    }
    return child;
  }

  Widget _gate({required Locale? locale, required Widget body}) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    locale: locale,
    home: Scaffold(body: body),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

/// Orchestrates language selection followed by the onboarding pages.
class _OnboardingFlow extends ConsumerStatefulWidget {
  const _OnboardingFlow();

  @override
  ConsumerState<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<_OnboardingFlow> {
  _OnboardingStage _stage = _OnboardingStage.language;

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _OnboardingStage.language => LanguageSelectionScreen(
        onLanguageSelected: () =>
            setState(() => _stage = _OnboardingStage.intro),
      ),
      _OnboardingStage.intro => OnboardingScreen(
        onFinish: () => setState(() => _stage = _OnboardingStage.preferences),
      ),
      _OnboardingStage.preferences => PreferencesScreen(
        onBack: () => setState(() => _stage = _OnboardingStage.intro),
        onComplete: () =>
            ref.read(onboardingControllerProvider.notifier).complete(),
      ),
    };
  }
}

enum _OnboardingStage { language, intro, preferences }

class _OnboardingLoading extends StatelessWidget {
  const _OnboardingLoading();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.onboardingLoading),
        ],
      ),
    );
  }
}

class _OnboardingError extends StatelessWidget {
  const _OnboardingError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.onboardingError),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('onboarding_retry'),
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}
