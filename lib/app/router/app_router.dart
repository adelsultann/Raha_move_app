import 'package:go_router/go_router.dart';

import '../config/mvp_features.dart';
import 'app_routes.dart';
import 'app_navigation_shell.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppNavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [$foundationRoute]),
        StatefulShellBranch(routes: [$savedRoutinesRoute]),
        if (MvpFeatures.gamification)
          StatefulShellBranch(routes: [$progressRoute]),
        StatefulShellBranch(routes: [$profileRoute]),
      ],
    ),
    if (MvpFeatures.recommendations) $checkInRoute,
    $reminderSettingsRoute,
    $profileHelpRoute,
    $profilePrivacyRoute,
    $profileTermsRoute,
    $exploreRoutineDetailsRoute,
    $exploreRoute,
    if (MvpFeatures.recommendations) $recommendationRoute,
    $routinePlayerRoute,
    $signInRoute,
    $signUpRoute,
    $emailConfirmationRoute,
  ],
);
