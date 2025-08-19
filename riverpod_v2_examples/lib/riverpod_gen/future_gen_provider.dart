import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'future_gen_provider.g.dart';

final prevCounterFutureProvider = FutureProvider((ref) {
  return 10;
});

@riverpod
Future<int> newCounter(Ref ref) async {
  return 10;
}

@riverpod //@Riverpod(keepAlive: true)
class NewClassCounter extends _$NewClassCounter {
  @override
  Future<int> build() async {
    final v = await ref.read(newCounterProvider.future);
    return Future.value(10 + v);
  }
}