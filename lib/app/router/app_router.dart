import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'app_navigation_shell.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppNavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [$foundationRoute]),
        StatefulShellBranch(routes: [$exploreRoute]),
        StatefulShellBranch(routes: [$progressRoute]),
        StatefulShellBranch(routes: [$profileRoute]),
      ],
    ),
    $checkInRoute,
    $reminderSettingsRoute,
    $profileHelpRoute,
    $profilePrivacyRoute,
    $profileTermsRoute,
    $exploreRoutineDetailsRoute,
    $savedRoutinesRoute,
    $recommendationRoute,
    $routinePlayerRoute,
    $signInRoute,
    $signUpRoute,
    $emailConfirmationRoute,
  ],
);
