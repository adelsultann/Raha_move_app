import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../application/profile_providers.dart';
import '../data/rpc_account_deletion_action.dart';

/// Runs before auth restoration, so an interrupted deletion cannot restore or
/// link the deleted account. A pending local cleanup is recoverable offline.
class AccountDeletionRecoveryGate extends ConsumerWidget {
  const AccountDeletionRecoveryGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recovery = ref.watch(accountDeletionRecoveryProvider);
    return recovery.when(
      loading: () =>
          _app((context) => _recoveryScreen(context, ref, isRetrying: true)),
      error: (_, _) => _app((context) => _recoveryScreen(context, ref)),
      data: (result) => result == AccountDeletionCleanupResult.completed
          ? child
          : _app((context) => _recoveryScreen(context, ref)),
    );
  }

  Widget _recoveryScreen(
    BuildContext context,
    WidgetRef ref, {
    bool isRetrying = false,
  }) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    strings.accountDeletionRecoveryTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.accountDeletionRecoveryBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isRetrying)
                    const CircularProgressIndicator()
                  else
                    FilledButton(
                      key: const Key('account_deletion_recovery_retry'),
                      onPressed: () =>
                          ref.invalidate(accountDeletionRecoveryProvider),
                      child: Text(strings.accountDeletionRecoveryRetry),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _app(WidgetBuilder bodyBuilder) => MaterialApp(
    // Recovery runs before the persisted profile may safely be read. Use the
    // device locale so its privacy message remains understandable in either
    // supported language without restoring deleted user state.
    locale: WidgetsBinding.instance.platformDispatcher.locale,
    home: Scaffold(body: Builder(builder: bodyBuilder)),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}
