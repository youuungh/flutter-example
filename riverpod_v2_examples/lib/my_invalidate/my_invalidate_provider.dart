import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberStateProvider = StateProvider((ref) => 100);

final numberNotifierProvider = NotifierProvider<NumberNotifier, int>(
  NumberNotifier.new,
);

class NumberNotifier extends Notifier<int> {
  @override
  int build() {
    return 1000;
  }

  increment() {
    state += 1;
  }
}
