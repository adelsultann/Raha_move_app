import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/l10n/app_localizations.dart';
import 'catalog_bootstrap_providers.dart';

/// Gates app startup until the local catalog is bootstrapped. It shows a
/// localized loading state and, on failure, a localized retry action, while the
/// already-applied catalog (bundled or previously synced) stays available to
/// the rest of the app. Once ready it renders [child].
class CatalogBootstrapGate extends ConsumerWidget {
  const CatalogBootstrapGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(catalogBootstrapProvider);
    return bootstrap.when(
      loading: () => _gateApp(const _BootstrapLoading()),
      error: (error, stackTrace) => _gateApp(_retry(context, ref)),
      data: (result) => result.isClean ? child : _gateApp(_retry(context, ref)),
    );
  }

  Widget _retry(BuildContext context, WidgetRef ref) => _BootstrapError(
    onRetry: () => ref.read(catalogBootstrapProvider.notifier).retry(),
  );

  Widget _gateApp(Widget body) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
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

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.catalogBootstrapLoading),
        ],
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.catalogBootstrapError),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('catalog_bootstrap_retry'),
            onPressed: onRetry,
            child: Text(strings.catalogBootstrapRetry),
          ),
        ],
      ),
    );
  }
}
