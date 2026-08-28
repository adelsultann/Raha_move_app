import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
