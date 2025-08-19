import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'post_api.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com")
abstract class PostApi {
  factory PostApi(Dio dio, {String baseUrl}) = _PostApi;

  @GET('/posts')
  Future<HttpResponse<dynamic>> getPosts();

  @POST('/posts')
  Future<HttpResponse<dynamic>> createPost(
    @Body() Map<String, dynamic> post,
  );

  @PUT('/posts/{id}')
  Future<HttpResponse<dynamic>> updatePost(
    @Path('id') int id,
    @Body() Map<String, dynamic> post,
  );

  @DELETE('/posts/{id}')
  Future<HttpResponse<dynamic>> deletePost(@Path('id') int id);
}
