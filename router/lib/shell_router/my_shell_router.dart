import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:router/main.dart';

GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey();
GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey();

final shellRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/user",
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: [
        GoRoute(path: "/user", builder: (context, state) => UserScreen()),
        GoRoute(path: "/login", builder: (context, state) => LoginScreen()),
      ],
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
    ),
  ],
);
