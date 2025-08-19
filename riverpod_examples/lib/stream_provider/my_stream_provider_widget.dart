import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'simple_stream_provider.dart';

class MyStreamProviderWidget extends ConsumerWidget {
  const MyStreamProviderWidget({super.key});

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   final counter = ref.watch(simpleStreamProvider);
  //   return counter.when(
  //     data: (data) {
  //       return Center(child: Text("$data"));
  //     },
  //     error: (error, trace) {
  //       return Center(child: Text("$error"));
  //     },
  //     loading: () {
  //       return Center(child: Text("로딩중"));
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(simpleStreamProvider);
    return switch (counter) {
      AsyncData(:final value) => Text("$value"),
      AsyncError(:final error) => Text("$error"),
      _ => Text("로딩중"),
    };
  }
}
