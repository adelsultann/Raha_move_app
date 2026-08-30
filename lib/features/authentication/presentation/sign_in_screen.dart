import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';

import 'auth_failure_message.dart';

/// Email/password sign-in. The existing-account path switches the active user
/// id without merging guest history (isolation is owned by the controller).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).value;
    final isBusy = auth?.isBusy ?? false;
    final failure = auth?.failure;

    return Scaffold(
      appBar: AppBar(title: Text(strings.signInTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              strings.signInTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('sign_in_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !isBusy,
              decoration: InputDecoration(
                labelText: strings.emailLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('sign_in_password'),
              controller: _password,
              obscureText: true,
              enabled: !isBusy,
              decoration: InputDecoration(
                labelText: strings.passwordLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  authFailureMessage(strings, failure),
                  key: const Key('sign_in_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('sign_in_submit'),
              onPressed: isBusy ? null : _submit,
              child: Text(
                isBusy ? strings.authenticating : strings.signInButton,
              ),
            ),
            TextButton(
              key: const Key('sign_in_create_account'),
              onPressed: () => const SignUpRoute().go(context),
              child: Text(strings.noAccountYet),
            ),
            TextButton(
              key: const Key('sign_in_continue_as_guest'),
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(strings.continueAsGuest),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;
    await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: email, password: password);
    if (!mounted) return;
    final state = ref.read(authControllerProvider).value;
    if (state != null &&
        state.failure == null &&
        state.status == AuthStatus.authenticated) {
      Navigator.of(context).maybePop();
    }
  }
}
