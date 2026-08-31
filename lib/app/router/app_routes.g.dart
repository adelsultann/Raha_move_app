// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $foundationRoute,
  $checkInRoute,
  $recommendationRoute,
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
