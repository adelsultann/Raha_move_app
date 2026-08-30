import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';

/// Gates app startup until a guest identity exists. Shows a localized loading
/// state while initializing and a recoverable retry state on failure; otherwise
/// it renders [child] (so a guest can always reach the core experience).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return auth.when(
      loading: () => _gate(const _AuthLoading()),
      error: (error, stackTrace) => _gate(
        _AuthError(onRetry: () => ref.invalidate(authControllerProvider)),
      ),
      data: (_) => child,
    );
  }

  Widget _gate(Widget body) => MaterialApp(
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

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.authLoading),
        ],
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.authInitError),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('auth_gate_retry'),
            onPressed: onRetry,
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}
