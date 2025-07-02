import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/rest_client/rest_client.dart';
import '../../main.dart';
import 'local_storage/display.dao.dart';
import 'mock/display/display_mock_api.dart';
import 'remote/display/display.api.dart';
import 'remote/user/user.api.dart';

@module
abstract class DataSourceModule {
  final Dio _dio = RestClient().getDio;

  @singleton
  DisplayApi get displayApi {
    String baseUrl = Platform.isAndroid
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';

    _dio.options.baseUrl = baseUrl;

    print('Using baseUrl: $baseUrl');
    print('Using Remote API: ${TargetApiValue().isRemoteApi}');

    //return DisplayMockApi();
    //return DisplayApi(_dio);
    return TargetApiValue().isRemoteApi ? DisplayApi(_dio) : DisplayMockApi();
  }

  @singleton
  UserApi get userApi =>
      UserApi(Dio()..options.baseUrl = dotenv.env['USER_API'] ?? '');

  @singleton
  DisplayDao get displayDao => DisplayDao();
}
