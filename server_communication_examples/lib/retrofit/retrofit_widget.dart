import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:server_communication_examples/retrofit/post_api.dart';

class RetrofitWidget extends StatefulWidget {
  const RetrofitWidget({super.key});

  @override
  State<RetrofitWidget> createState() => _RetrofitWidgetState();
}

class _RetrofitWidgetState extends State<RetrofitWidget> {
  late Dio dio;
  late PostApi postApi;
  String responseText = "";

  @override
  void initState() {
    super.initState();
    _initRetrofit();
  }

  void _initRetrofit() {
    dio = Dio();
    dio.options.headers = {
      'User-Agent': 'Flutter App',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    postApi = PostApi(dio);
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
              final response = await postApi.getPosts();
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Retrofit GET"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await postApi.createPost({
                'title': 'Test',
                'body': 'Test body',
                'userId': 1,
              });
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Retrofit POST"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await postApi.updatePost(1, {
                'title': 'Updated title',
                'body': 'Updated body',
                'userId': 1,
              });
              setState(() {
                responseText = _formatJson(response.data);
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Retrofit PUT"),
        ),
        TextButton(
          onPressed: () async {
            try {
              final response = await postApi.deletePost(1);
              setState(() {
                responseText = 'Deleted successfully: ${response.data}';
              });
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text("Retrofit DELETE"),
        ),
        Divider(),
        Expanded(child: SingleChildScrollView(child: Text(responseText))),
      ],
    );
  }
}
