import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class DioWidget extends StatefulWidget {
  const DioWidget({super.key});

  @override
  State<DioWidget> createState() => _DioWidgetState();
}

class _DioWidgetState extends State<DioWidget> {
  late Dio dio;
  String responseText = "";

  @override
  void initState() {
    super.initState();
    _initDio();
  }

  void _initDio() {
    dio = Dio();
    dio.options.headers = {
      'User-Agent': 'Flutter App',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  String _formatJson(dynamic data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            try {
              final response = await dio.get(api);
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print(e);
            }
          },
          child: Text("Dio GET"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await dio.post(
                api,
                data: {'title': 'Test', 'body': 'Test body', 'userId': 1},
              );
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Dio POST"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await dio.put(
                '$api/1',
                data: {
                  'title': 'Updated Title',
                  'body': 'Updated body',
                  'userId': 1,
                },
              );
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Dio PUT"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await dio.delete('$api/1');
              setState(() {
                responseText = 'Deleted successfully: ${response.data}';
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Dio DELETE"),
        ),
        Divider(),
        Expanded(child: SingleChildScrollView(child: Text(responseText))),
      ],
    );
  }
}
