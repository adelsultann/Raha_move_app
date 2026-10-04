import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../../../app/router/app_routes.dart';
import '../../authentication/application/auth_controller.dart';
import '../../authentication/domain/auth_state.dart';
import '../application/profile_controller.dart';
import '../application/profile_providers.dart';
import '../domain/account_deletion_action.dart';
import 'profile_menu_widgets.dart';

class ProfileAccountSection extends ConsumerWidget {
  const ProfileAccountSection({super.key, required this.auth});
  final AuthState? auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final registered = auth?.status == AuthStatus.authenticated;
    return Column(
      children: [
        if (!registered) ...[
          ProfileMenuTile(
            tileKey: const Key('profile_log_in'),
            icon: Icons.login,
            title: s.profileLogIn,
            onTap: () => const SignInRoute().push(context),
          ),
          ProfileMenuTile(
            tileKey: const Key('profile_create_account'),
            icon: Icons.person_add_alt_outlined,
            title: s.profileCreateAccountAction,
            onTap: () => const SignUpRoute().push(context),
          ),
        ] else ...[
          ProfileMenuTile(
            tileKey: const Key('profile_sign_out'),
            icon: Icons.logout,
            title: s.signOut,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
        ProfileMenuTile(
          tileKey: const Key('profile_delete_account'),
          icon: Icons.delete_outline,
          title: s.profileDeleteAccount,
          onTap: auth == null
              ? null
              : () => _confirmDeletion(context, ref, registered),
        ),
      ],
    );
  }

  Future<void> _confirmDeletion(
    BuildContext context,
    WidgetRef ref,
    bool registered,
  ) async {
    final s = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.profileDeleteConfirmTitle),
        content: Text(
          registered ? s.profileDeleteRegisteredBody : s.profileDeleteGuestBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            key: const Key('profile_confirm_delete'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(s.profileDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(accountDeletionActionProvider)
        .requestDeletion(isRegisteredAccount: registered);
    if (!context.mounted) return;
    if (result == AccountDeletionResult.accepted) {
      ref.invalidate(authControllerProvider);
      ref.invalidate(profileControllerProvider);
    }
    if (result == AccountDeletionResult.acceptedWithPendingCleanup) {
      ref.invalidate(accountDeletionRecoveryProvider);
    }
    final message = switch (result) {
      AccountDeletionResult.accepted => s.profileDeleteAccepted,
      AccountDeletionResult.acceptedWithPendingCleanup =>
        s.profileDeleteAcceptedCleanupPending,
      AccountDeletionResult.requiresRecentSignIn =>
        s.profileDeleteRequiresSignIn,
      AccountDeletionResult.unavailable => s.profileDeleteUnavailable,
      AccountDeletionResult.failed => s.profileDeleteFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: result == AccountDeletionResult.requiresRecentSignIn
            ? SnackBarAction(
                label: s.signInButton,
                onPressed: () => const SignInRoute().push(context),
              )
            : null,
      ),
    );
  }
}
