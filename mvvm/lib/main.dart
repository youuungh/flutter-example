import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm/view_model/post_view_model.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            /// 1
            // final viewModel = ref.read(postViewModelProvider);
            //
            // return FutureBuilder(
            //   future: viewModel.getPosts(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       final value = snapshot.data ?? [];
            //       if (value.isEmpty) {
            //         return Center(
            //           child: Text("아이템이 없습니다."),
            //         );
            //       }
            //       return ListView.builder(
            //         itemCount: value.length,
            //         itemBuilder: (context, index) {
            //           return ListTile(
            //             title: Text("${value[index].id}"),
            //             subtitle: Text("${value[index].title}"),
            //           );
            //         },
            //       );
            //     }
            //     return Center(
            //       child: CircularProgressIndicator.adaptive(),
            //     );
            //   },
            // );

            /// 2
            // final posts = ref.watch(fetchPostsProvider);
            //
            // return switch (posts) {
            //   AsyncData(:final value) => ListView.builder(
            //       itemCount: value?.length,
            //       itemBuilder: (context, index) {
            //         return ListTile(
            //           title: Text("${value?[index].id}"),
            //           subtitle: Text("${value?[index].title}"),
            //         );
            //       },
            //     ),
            //   AsyncError(:final error) => Text("$error"),
            //   _ => Center(
            //       child: CircularProgressIndicator.adaptive(),
            //     ),
            // };

            /// 3
            final posts = ref.watch(asyncPostsGenNotifierProvider);

            return posts.when(
              data: (data) {
                return ListView.builder(
                  itemCount: data?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("${data?[index].id}"),
                      subtitle: Text("${data?[index].title}"),
                    );
                  },
                );
              },
              error: (error, trace) {
                return Text("$error");
              },
              loading: () {
                return Center(child: CircularProgressIndicator.adaptive());
              },
            );
          },
        ),
      ),
    );
  }
}
