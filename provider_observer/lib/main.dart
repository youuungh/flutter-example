import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    // TODO: implement didAddProvider
    // super.didAddProvider(provider, value, container);
    print('''
      {
        "provider" : "${provider.name ?? provider.runtimeType}"
        "value" : "$value"
      }
    ''');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // TODO: implement didUpdateProvider
    // super.didUpdateProvider(provider, previousValue, newValue, container);
    print('''
      {
        "provider" : "${provider.name ?? provider.runtimeType}",
        "previousValue" : "$previousValue",
        "newValue" : "$newValue"
      }
    ''');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    // TODO: implement didDisposeProvider
    // super.didDisposeProvider(provider, container);
    print('''
      didDisposeProvider
      {
        "provider" : "${provider.name ?? provider.runtimeType}"
      }
    ''');
  }
}

final counterStateProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
  name: "counterStateProvider",
);

void main() {
  runApp(ProviderScope(observers: [ProviderLogger()], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const SecondPage()));
          },
          child: Text("페이지 이동"),
        ),
      ),
    );
  }
}

class SecondPage extends ConsumerWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterStateProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          '$counter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterStateProvider.notifier).state++;
        },
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Consumer(
//               builder: (context, ref, child) {
//                 final counter = ref.watch(counterStateProvider);
//                 return Text(
//                   '$counter',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 );
//               }
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Consumer(
//         builder: (context, ref, child) {
//           return FloatingActionButton(
//             onPressed: () {
//               ref.read(counterStateProvider.notifier).state++;
//             },
//             tooltip: 'Increment',
//             child: const Icon(Icons.add),
//           );
//         }
//       ),
//     );
//   }
// }
