import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/features/authentication/presentation/email_confirmation_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_in_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_up_screen.dart';

import '../localization/l10n/app_localizations.dart';

part 'app_routes.g.dart';

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData with $FoundationRoute {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          header: true,
          child: Text(strings.foundationMessage, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<EmailConfirmationRoute>(path: '/email-confirmation')
class EmailConfirmationRoute extends GoRouteData with $EmailConfirmationRoute {
  const EmailConfirmationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EmailConfirmationScreen();
}
