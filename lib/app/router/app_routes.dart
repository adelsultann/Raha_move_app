import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/features/authentication/presentation/email_confirmation_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_in_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_up_screen.dart';
import 'package:raha_move/features/check_in/application/check_in_controller.dart';
import 'package:raha_move/features/check_in/presentation/check_in_screen.dart';
import 'package:raha_move/features/recommendations/presentation/recommendation_screen.dart';
import 'package:raha_move/features/routine_player/presentation/routine_player_screen.dart';

import '../localization/l10n/app_localizations.dart';

part 'app_routes.g.dart';

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData with $FoundationRoute {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    strings.foundationMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.checkInStartSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('start_check_in'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => const CheckInRoute().push(context),
                  child: Text(strings.checkInStartTitle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@TypedGoRoute<CheckInRoute>(path: '/check-in')
class CheckInRoute extends GoRouteData with $CheckInRoute {
  const CheckInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Consumer(
      builder: (context, ref, _) => CheckInScreen(
        onExit: () => context.pop(),
        onComplete: () => _openRecommendation(context, ref),
      ),
    );
  }

  void _openRecommendation(BuildContext context, WidgetRef ref) {
    final checkInId = ref
        .read(checkInControllerProvider.notifier)
        .completedCheckInId;
    if (checkInId == null) {
      context.pop();
      return;
    }
    RecommendationRoute(checkInId: checkInId).pushReplacement(context);
  }
}

@TypedGoRoute<RecommendationRoute>(path: '/recommendation/:checkInId')
class RecommendationRoute extends GoRouteData with $RecommendationRoute {
  const RecommendationRoute({required this.checkInId});

  final String checkInId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecommendationScreen(
      checkInId: checkInId,
      onStart: (routineId, recommendationId) {
        RoutinePlayerRoute(
          routineId: routineId,
          recommendationId: recommendationId,
        ).push(context);
      },
      onEditCheckIn: () => context.pop(),
    );
  }
}

@TypedGoRoute<RoutinePlayerRoute>(path: '/routine/:routineId')
class RoutinePlayerRoute extends GoRouteData with $RoutinePlayerRoute {
  const RoutinePlayerRoute({
    required this.routineId,
    @TypedQueryParameter(name: 'recommendationId') this.recommendationId,
    @TypedQueryParameter(name: 'sessionId') this.sessionId,
  });

  final String routineId;

  final String? recommendationId;

  /// Stable identifier used to restore a previously started session. A null
  /// [sessionId] starts a new session.
  final String? sessionId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RoutinePlayerScreen(
      routineId: routineId,
      recommendationId: recommendationId,
      sessionId: sessionId,
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
