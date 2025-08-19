import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String jsonUrl = "https://jsonplaceholder.typicode.com/posts/";

final tempProvider = StateProvider.family((ref, int arg) => arg + 0);

final idStateProvider = StateProvider((ref) => 1);

final postFutureProviderFamily = FutureProvider.family((ref, int id) async {
  final _id = ref.watch(idStateProvider);
  final response = await http.get(
    Uri.parse("$jsonUrl$_id"),
    headers: {
      'User-Agent': 'Flutter App',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load post: ${response.statusCode}');
  }
});

final postFutureProvider = FutureProvider.autoDispose((ref) async {
  ref.onDispose(() {
    print("onDispose");
  });
  final response = await http.get(
    Uri.parse("${jsonUrl}1"),
    headers: {
      'User-Agent': 'Flutter App',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load post: ${response.statusCode}');
  }
});

void main() {
  // final container = ProviderContainer();
  // final tempContainer1 = container.read(tempProvider(1));
  // final tempContainer2 = container.read(tempProvider(2));
  // print(tempContainer1.toString());
  // print(tempContainer2.toString());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FirstPage(title: 'Modifier'),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title});

  final String title;

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      // body: Center(
      //   child: Consumer(
      //     builder: (context, ref, child) {
      //       final id = ref.watch(idStateProvider);
      //       final post = ref.watch(postFutureProviderFamily(id));
      //       return post.when(
      //         data: (data) {
      //           return Text("$data");
      //         },
      //         error: (error, stackTrace) => Text("$error"),
      //         loading: () => CircularProgressIndicator(),
      //       );
      //     },
      //   ),
      // ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => SecondPage()));
          },
          child: Text("Go to Second Page"),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () {
              ref.read(idStateProvider.notifier).update((state) => state += 1);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final post = ref.watch(postFutureProvider);
            return post.when(
              data: (data) {
                return Text(data);
              },
              error: (error, stackTrace) {
                return Text("$error");
              },
              loading: () => CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
