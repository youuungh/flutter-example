import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'model.dart';
import 'screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CounterModel>(
          create: (context) => CounterModel(),
        ),
        Provider<CounterModeModel>(
          create: (context) => CounterModeModel(),
        ),
      ],
      child: const CounterApp(),
    ),
  );
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}
