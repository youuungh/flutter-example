import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:router/shell_router/my_shell_router.dart';

import 'go_router_builder/builder_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(routes: $appRoutes);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: shellRouter);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.child});

  final Widget? child;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) {
          if (index == 0) {
            GoRouter.of(context).go("/login");
          } else {
            GoRouter.of(context).go("/user");
          }
          setState(() {
            pageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "로그인"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: "프로필",
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Login 화면"));
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("User Screen"),
        Center(child: Text("User $userId")),
      ],
    );
  }
}
