import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('provider'),
        actions: [
          IconButton(
            onPressed: () => onChangedMode(context),
            icon: const Icon(CupertinoIcons.arrow_2_squarepath),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              context.read<CounterModel>().counter.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => execute(context),
        child: Icon(context.read<CounterModeModel>().counterMode.icon),
      ),
    );
  }

  void onChangedMode(BuildContext context) {
    setState(() {
      context.read<CounterModeModel>().toggleMode();
    });
  }

  void execute(BuildContext context) {
    setState(() {
      switch (context.read<CounterModeModel>().counterMode) {
        case CounterMode.plus:
          context.read<CounterModel>().increment();
        case CounterMode.minus:
          context.read<CounterModel>().decrement();
      }
    });
  }
}

extension on CounterMode {
  IconData get icon {
    switch (this) {
      case CounterMode.plus:
        return CupertinoIcons.add;
      case CounterMode.minus:
        return CupertinoIcons.minus;
    }
  }
}