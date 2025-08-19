import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_v2_examples/async_notifier_provider/my_async_notifier_provider.dart';
import 'package:riverpod_v2_examples/my_invalidate/my_invalidate_provider.dart';
import 'package:riverpod_v2_examples/notifier_provider/my_notifier_provider.dart';
import 'package:riverpod_v2_examples/override_with_value/override_counter.dart';
import 'package:riverpod_v2_examples/riverpod_gen/future_gen_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        //counterOverrideStateProvider.overrideWith((ref) => 100),
        sharedPreferencesProvider.overrideWithValue(pref),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// notifier
              // Consumer(
              //   builder: (context, ref, child) {
              //     //final count = ref.watch(counterNotifierProvider);
              //     final count = ref.watch(asyncCounterNotifierProvider);
              //     // return Center(
              //     //   child: Text("$count", style: TextStyle(fontSize: 24)),
              //     // );
              //     return count.when(
              //       data: (data) {
              //         return Center(
              //           child: Text("$data", style: TextStyle(fontSize: 24)),
              //         );
              //       },
              //       error: (error, stackTrace) => Text("$error"),
              //       loading: () =>
              //           Center(child: CircularProgressIndicator.adaptive()),
              //     );
              //   },
              // ),

              /// riverpod_gen
              // Consumer(
              //   builder: (context, ref, child) {
              //     //final counter = ref.watch(newCounterProvider);
              //     final counter = ref.watch(newClassCounterProvider);
              //     return counter.when(
              //       data: (data) => Center(child: Text("$data")),
              //       error: (error, stackTrace) => Text("$error"),
              //       loading: () => CircularProgressIndicator.adaptive(),
              //     );
              //   },
              // ),

              /// invalidate
              // Center(
              //   child: Consumer(
              //     builder: (context, ref, child) {
              //       //final number = ref.watch(numberStateProvider);
              //       //final number = ref.watch(numberNotifierProvider);
              //       final number = ref.watch(asyncCounterNotifierProvider);
              //       //return Text("$number", style: TextStyle(fontSize: 32));
              //       return switch(number) {
              //         AsyncData(:final value) => Text("$value", style: TextStyle(fontSize: 32)),
              //         AsyncError(:final error) => Text("$error", style: TextStyle(fontSize: 32)),
              //         AsyncLoading() => CircularProgressIndicator.adaptive(),
              //         AsyncValue<int>() => throw UnimplementedError(),
              //       };
              //     },
              //   ),
              // ),
              // Consumer(
              //   builder: (context, ref, child) {
              //     return TextButton(
              //       onPressed: () {
              //         ref
              //             //.read(numberStateProvider.notifier)
              //             //.update((state) => state += 1);
              //         //.read(numberNotifierProvider.notifier).increment();
              //         .read(asyncCounterNotifierProvider.notifier).increment();
              //       },
              //       child: Text("카운트 증가"),
              //     );
              //   },
              // ),
              // Consumer(builder: (context, ref, child) {
              //   return TextButton(
              //     onPressed: () {
              //       //ref.invalidate(numberStateProvider);
              //       //ref.invalidate(numberNotifierProvider);
              //       ref.invalidate(asyncCounterNotifierProvider);
              //     },
              //     child: Text("카운트 초기화"),
              //   );
              // }),

              ///override
              Consumer(
                builder: (context, ref, child) {
                  final counter = ref.watch(counterOverrideStateProvider);
                  return Center(
                    child: Text("$counter", style: TextStyle(fontSize: 32)),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            return FloatingActionButton(
              onPressed: () {
                ref.read(counterNotifierProvider.notifier).increment();
              },
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
