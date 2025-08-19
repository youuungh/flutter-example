import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm/model/post_model.dart';
import 'package:mvvm/service/post_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_view_model.g.dart';

final postViewModelProvider = Provider((ref) {
  final service = ref.read(postServiceProvider);
  return PostViewModel(service);
});

final fetchPostsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(postViewModelProvider).getPosts();
});

final fetchPostsProvider2 = FutureProvider.autoDispose((ref) async {
  try {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      "https://jsonplaceholder.typicode.com/posts",
    );
    List<dynamic> jsonList = response.data;
    List<PostModel> posts = jsonList
        .map((json) => PostModel.fromJson(json))
        .toList();
    return posts;
  } catch (e) {
    print('Error fetching posts: $e');
    return <PostModel>[];
  }
});

class PostViewModel {
  PostServiceImpl? postServiceImpl;

  PostViewModel(this.postServiceImpl);

  Future<List<PostModel>?> getPosts() async {
    try {
      final posts = await postServiceImpl?.getPosts();
      return posts;
    } on DioException catch (e) {
      print(e.toString());
    }
  }
}

final asyncPostNotifier =
    AsyncNotifierProvider<AsyncPostNotifier, List<PostModel>>(
      AsyncPostNotifier.new,
    );

class AsyncPostNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  FutureOr<List<PostModel>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        "https://jsonplaceholder.typicode.com/posts",
      );

      List<dynamic> jsonList = response.data;
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return <PostModel>[];
    }
  }

  void add() {}

  void plus() {}

  void remove() {}
}

@riverpod
class AsyncPostsGenNotifier extends _$AsyncPostsGenNotifier {
  Future<List<PostModel>> _fetchPosts() async {
    try {
      Dio dio = Dio();
      final response = await dio.get("https://jsonplaceholder.typicode.com/posts");

      List<dynamic> jsonList = response.data;
      return jsonList
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return <PostModel>[];
    }
  }

  @override
  Future<List<PostModel>> build() async {
    return await _fetchPosts();
  }
}