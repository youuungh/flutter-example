import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:router/main.dart';

part 'builder_router.g.dart';

@TypedGoRoute<HomeRoute>(
  path: "/",
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<UserRoute>(path: "user/:userId"),
  ],
)
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HomeScreen();
  }
}

@TypedGoRoute<LoginRoute>(path: "/login")
class LoginRoute extends GoRouteData with _$LoginRoute {
  LoginRoute(this.from);

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen();
  }
}

class UserRoute extends GoRouteData with _$UserRoute {
  const UserRoute(this.userId);

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserScreen(userId: userId);
  }
}
