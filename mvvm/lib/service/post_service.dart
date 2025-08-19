import 'package:dio/dio.dart';
import 'package:mvvm/model/post_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final postRepository = Provider((ref) {
  return PostRepositoryImpl(ref.read(postServiceProvider));
});

/// service --> repository
final postServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return PostServiceImpl(dio);
});

final dioProvider = Provider((ref) {
  final dio = Dio();
  dio.options.headers = {
    'User-Agent': 'Flutter App',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  return dio;
});

abstract class PostRepository {
  Future<List<PostModel>?> getPosts();
}

class PostRepositoryImpl extends PostRepository {
  PostServiceImpl postServiceImpl;

  PostRepositoryImpl(this.postServiceImpl);

  @override
  Future<List<PostModel>?> getPosts() async {
    return await postServiceImpl.getPosts();
  }
}

abstract class PostService {
  Future<List<PostModel>?> getPosts();
}

class PostServiceImpl extends PostService {
  Dio dio;

  PostServiceImpl(this.dio);

  @override
  Future<List<PostModel>?> getPosts() async {
    try {
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
  }
}
