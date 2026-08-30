import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';

/// Calm confirmation screen shown after registration (or an unconfirmed sign-in).
class EmailConfirmationScreen extends ConsumerWidget {
  const EmailConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).value;
    final email = auth?.pendingEmail;
    final isBusy = auth?.isBusy ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(strings.emailConfirmationTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              strings.emailConfirmationTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              email == null
                  ? strings.checkYourEmail
                  : strings.emailConfirmationBody(email),
              key: const Key('email_confirmation_body'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('email_confirmation_resend'),
              onPressed: isBusy
                  ? null
                  : () {
                      final address = email;
                      if (address != null) {
                        ref
                            .read(authControllerProvider.notifier)
                            .resendConfirmation(email: address);
                      }
                    },
              child: Text(
                isBusy ? strings.authenticating : strings.resendConfirmation,
              ),
            ),
            TextButton(
              key: const Key('email_confirmation_continue'),
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(strings.continueAsGuest),
            ),
          ],
        ),
      ),
    );
  }
}
