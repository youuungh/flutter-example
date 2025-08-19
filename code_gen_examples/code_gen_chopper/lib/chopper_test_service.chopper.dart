// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chopper_test_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TodoService extends TodoService {
  _$TodoService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TodoService;

  @override
  Future<Response<dynamic>> getTodos() {
    final Uri $url = Uri.parse('/todo');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
