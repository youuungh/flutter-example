import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final asyncCounterNotifierProvider =
    AsyncNotifierProvider<AsyncCounterNotifier, int>(AsyncCounterNotifier.new);

class AsyncCounterNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() async {
    Dio dio = Dio();
    dio.options.headers = {
      'User-Agent': 'Flutter App',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final response = await dio.get(
      "https://jsonplaceholder.typicode.com/users",
    );
    print(response.data);

    final users = response.data as List<dynamic>;

    return users.length;
  }

  sampleMethod() {
    state = AsyncValue.loading();
  }

  increment() {
    state = const AsyncValue.loading();
    var old = state.value ?? 0;
    old += 1;
    state = AsyncValue.data(old);
  }
}
