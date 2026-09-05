import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raha_move/features/authentication/presentation/email_confirmation_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_in_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_up_screen.dart';
import 'package:raha_move/features/check_in/application/check_in_controller.dart';
import 'package:raha_move/features/check_in/presentation/check_in_screen.dart';
import 'package:raha_move/features/explore/presentation/explore_routine_details_screen.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/progress/presentation/progress_screen.dart';
import 'package:raha_move/features/recommendations/presentation/recommendation_screen.dart';
import 'package:raha_move/features/routine_player/presentation/routine_player_screen.dart';
import 'package:raha_move/features/saved_routines/presentation/saved_routines_screen.dart';
import 'package:raha_move/features/today/presentation/today_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData with $FoundationRoute {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TodayScreen(
      onStartCheckIn: () => const CheckInRoute().push(context),
      onResume: (routineId, sessionId) => RoutinePlayerRoute(
        routineId: routineId,
        sessionId: sessionId,
      ).push(context),
      onRepeat: (routineId) =>
          RoutinePlayerRoute(routineId: routineId).push(context),
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

@TypedGoRoute<ExploreRoute>(path: '/explore')
class ExploreRoute extends GoRouteData with $ExploreRoute {
  const ExploreRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ExploreScreen();
}

@TypedGoRoute<ProgressRoute>(path: '/progress')
class ProgressRoute extends GoRouteData with $ProgressRoute {
  const ProgressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProgressScreen();
}

@TypedGoRoute<ExploreRoutineDetailsRoute>(path: '/explore/routine/:routineId')
class ExploreRoutineDetailsRoute extends GoRouteData
    with $ExploreRoutineDetailsRoute {
  const ExploreRoutineDetailsRoute({required this.routineId});
  final String routineId;
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ExploreRoutineDetailsScreen(routineId: routineId);
}

@TypedGoRoute<SavedRoutinesRoute>(path: '/saved-routines')
class SavedRoutinesRoute extends GoRouteData with $SavedRoutinesRoute {
  const SavedRoutinesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SavedRoutinesScreen();
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
    @TypedQueryParameter(name: 'source') this.source,
  });

  final String routineId;

  final String? recommendationId;

  /// Stable identifier used to restore a previously started session. A null
  /// [sessionId] starts a new session.
  final String? sessionId;
  final String? source;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RoutinePlayerScreen(
      routineId: routineId,
      recommendationId: recommendationId,
      sessionId: sessionId,
      source: source,
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
