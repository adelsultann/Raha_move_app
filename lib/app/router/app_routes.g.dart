// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $foundationRoute,
  $checkInRoute,
  $exploreRoute,
  $exploreRoutineDetailsRoute,
  $savedRoutinesRoute,
  $recommendationRoute,
  $routinePlayerRoute,
  $signInRoute,
  $signUpRoute,
  $emailConfirmationRoute,
];

RouteBase get $foundationRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $FoundationRoute._fromState,
);

mixin $FoundationRoute on GoRouteData {
  static FoundationRoute _fromState(GoRouterState state) =>
      const FoundationRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $checkInRoute => GoRouteData.$route(
  path: '/check-in',
  hasOverriddenOnExit: false,
  factory: $CheckInRoute._fromState,
);

mixin $CheckInRoute on GoRouteData {
  static CheckInRoute _fromState(GoRouterState state) => const CheckInRoute();

  @override
  String get location => GoRouteData.$location('/check-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $exploreRoute => GoRouteData.$route(
  path: '/explore',
  hasOverriddenOnExit: false,
  factory: $ExploreRoute._fromState,
);

mixin $ExploreRoute on GoRouteData {
  static ExploreRoute _fromState(GoRouterState state) => const ExploreRoute();

  @override
  String get location => GoRouteData.$location('/explore');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $exploreRoutineDetailsRoute => GoRouteData.$route(
  path: '/explore/routine/:routineId',
  hasOverriddenOnExit: false,
  factory: $ExploreRoutineDetailsRoute._fromState,
);

mixin $ExploreRoutineDetailsRoute on GoRouteData {
  static ExploreRoutineDetailsRoute _fromState(GoRouterState state) =>
      ExploreRoutineDetailsRoute(routineId: state.pathParameters['routineId']!);

  ExploreRoutineDetailsRoute get _self => this as ExploreRoutineDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/explore/routine/${Uri.encodeComponent(_self.routineId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $savedRoutinesRoute => GoRouteData.$route(
  path: '/saved-routines',
  hasOverriddenOnExit: false,
  factory: $SavedRoutinesRoute._fromState,
);

mixin $SavedRoutinesRoute on GoRouteData {
  static SavedRoutinesRoute _fromState(GoRouterState state) =>
      const SavedRoutinesRoute();

  @override
  String get location => GoRouteData.$location('/saved-routines');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $recommendationRoute => GoRouteData.$route(
  path: '/recommendation/:checkInId',
  hasOverriddenOnExit: false,
  factory: $RecommendationRoute._fromState,
);

mixin $RecommendationRoute on GoRouteData {
  static RecommendationRoute _fromState(GoRouterState state) =>
      RecommendationRoute(checkInId: state.pathParameters['checkInId']!);

  RecommendationRoute get _self => this as RecommendationRoute;

  @override
  String get location => GoRouteData.$location(
    '/recommendation/${Uri.encodeComponent(_self.checkInId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $routinePlayerRoute => GoRouteData.$route(
  path: '/routine/:routineId',
  hasOverriddenOnExit: false,
  factory: $RoutinePlayerRoute._fromState,
);

mixin $RoutinePlayerRoute on GoRouteData {
  static RoutinePlayerRoute _fromState(GoRouterState state) =>
      RoutinePlayerRoute(
        routineId: state.pathParameters['routineId']!,
        recommendationId: state.uri.queryParameters['recommendationId'],
        sessionId: state.uri.queryParameters['sessionId'],
        source: state.uri.queryParameters['source'],
      );

  RoutinePlayerRoute get _self => this as RoutinePlayerRoute;

  @override
  String get location => GoRouteData.$location(
    '/routine/${Uri.encodeComponent(_self.routineId)}',
    queryParams: {
      if (_self.recommendationId != null)
        'recommendationId': _self.recommendationId,
      if (_self.sessionId != null) 'sessionId': _self.sessionId,
      if (_self.source != null) 'source': _self.source,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
  path: '/sign-up',
  hasOverriddenOnExit: false,
  factory: $SignUpRoute._fromState,
);

mixin $SignUpRoute on GoRouteData {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $emailConfirmationRoute => GoRouteData.$route(
  path: '/email-confirmation',
  hasOverriddenOnExit: false,
  factory: $EmailConfirmationRoute._fromState,
);

mixin $EmailConfirmationRoute on GoRouteData {
  static EmailConfirmationRoute _fromState(GoRouterState state) =>
      const EmailConfirmationRoute();

  @override
  String get location => GoRouteData.$location('/email-confirmation');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
