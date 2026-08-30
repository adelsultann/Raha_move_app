import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/application/locale_controller.dart';
import 'localization/l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// The main application `MaterialApp`. The active [Locale] is driven by
/// [LocaleController] so a language choice applies its directionality and
/// localized strings across the whole app.
class RahaMoveApp extends ConsumerWidget {
  const RahaMoveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider).value;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
