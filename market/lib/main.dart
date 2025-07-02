import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market/home/cart_screen.dart';
import 'package:market/home/home_screen.dart';
import 'package:market/home/product_detail_screen.dart';
import 'package:market/login/login_screen.dart';
import 'package:market/login/sign_up_screen.dart';
import 'package:market/model/product.dart';

import 'firebase_options.dart';

List<CameraDescription> cameras = [];
UserCredential? userCredential;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  cameras = await availableCameras();

  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
      FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
      FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    } catch (e) {
      print(e);
    }
  }
  runApp(ProviderScope(child: MarketApp()));
}

class MarketApp extends ConsumerWidget {
  const MarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: "/",
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLoggedIn = user != null;
        final isLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/sign_up';


        if (!isLoggedIn && !isLoginPage) {
          return '/login';
        }

        if (isLoggedIn && isLoginPage) {
          return '/';
        }

        return null;
      },
      refreshListenable: _AuthChangeNotifier(),
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: "cart/:uid",
              builder: (context, state) =>
                  CartScreen(uid: state.pathParameters["uid"] ?? ""),
            ),
            GoRoute(
              path: "product",
              builder: (context, state) =>
                  ProductDetailScreen(product: state.extra as Product),
            ),
            GoRoute(
              path: "product/add",
              builder: (context, state) =>
                  ProductDetailScreen(product: state.extra as Product),
            ),
          ],
        ),
        GoRoute(path: "/login", builder: (context, state) => LoginScreen()),
        GoRoute(path: "/sign_up", builder: (context, state) => SignUpScreen()),
      ],
    );

    return MaterialApp.router(
      title: '_market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}