import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dto/product_info.dto.dart';
import 'dto/view_module.dto.dart';

part 'data.dart';
part 'request.dart';

// Configure routes.
Handler handler = (Router()
  ..get('/', swaggerUIHandler)  // 루트에서 Swagger UI 제공
  ..get('/api-docs', apiDocsHandler)  // ../specs/swagger.yaml 제공
  ..get('/api/menus/<mallType>', menuHandler)
  ..get('/api/view-modules/<tabId>/<page>', viewModuleHandler)).call;

void main(List<String> args) async {
  final server = await serve(handler, '127.0.0.1', 8080);
  print('Server listening on http://localhost:${server.port}');
  print('Swagger UI: http://localhost:${server.port}');
  print('Using ../specs/swagger.yaml for API documentation');
}