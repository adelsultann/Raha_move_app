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
          _app((_) => const Center(child: CircularProgressIndicator())),
      error: (_, _) => _app((context) => _retry(context, ref)),
      data: (result) => result == AccountDeletionCleanupResult.completed
          ? child
          : _app((context) => _retry(context, ref)),
    );
  }

  Widget _retry(BuildContext context, WidgetRef ref) => Center(
    child: FilledButton(
      key: const Key('account_deletion_recovery_retry'),
      onPressed: () => ref.invalidate(accountDeletionRecoveryProvider),
      child: Text(AppLocalizations.of(context).accountDeletionRecoveryRetry),
    ),
  );

  Widget _app(WidgetBuilder bodyBuilder) => MaterialApp(
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
