import 'package:chopper/chopper.dart';

part 'chopper_test_service.chopper.dart';

@ChopperApi(baseUrl: "/todo")
abstract class TodoService extends ChopperService {
  static TodoService create(ChopperClient? client) => _$TodoService(client);

  @GET()
  Future<Response> getTodos();
}