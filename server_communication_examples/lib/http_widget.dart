import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class HttpWidget extends StatefulWidget {
  const HttpWidget({super.key});

  @override
  State<HttpWidget> createState() => _HttpWidgetState();
}

class _HttpWidgetState extends State<HttpWidget> {
  String responseText = "";

  final Map<String, String> headers = {
    'User-Agent': 'Flutter App',
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            final response = await http.get(
              Uri.parse(api),
              headers: headers,
            );

            if (response.statusCode == 200) {
              setState(() {
                responseText = response.body;
              });
            } else {
              throw Exception(
                "Failed to get data: ${response.statusCode}",
              );
            }
          },
          child: Text("Http GET"),
        ),
        TextButton(
          onPressed: () async {
            final response = await http.post(
              Uri.parse(api),
              headers: headers,
              body: jsonEncode({
                "title": "Test",
                "body": "Test body",
                "userId": 1,
              }),
            );

            if (response.statusCode == 201) {
              setState(() {
                responseText = response.body;
              });
            } else {
              throw Exception(
                "Failed to post data: ${response.statusCode}",
              );
            }
          },
          child: Text("Http POST"),
        ),
        TextButton(
          onPressed: () {
            http
                .put(
              Uri.parse("$api/1"),
              headers: headers,
              body: jsonEncode({
                "title": "Test",
                "body": "Test body",
                "userId": 1,
              }),
            )
                .then((response) {
              print(response.statusCode);
              if (response.statusCode == 200) {
                setState(() {
                  responseText = response.body;
                });
              } else {
                throw Exception(
                  "Failed to put data: ${response.statusCode}",
                );
              }
            });
          },
          child: Text("Http PUT"),
        ),
        TextButton(
          onPressed: () {
            http.delete(Uri.parse("$api/1"), headers: headers).then((
                response,
                ) {
              print(response.statusCode);
              if (response.statusCode == 200) {
                setState(() {
                  responseText = response.body;
                });
              } else {
                throw Exception(
                  "Failed to delete data: ${response.statusCode}",
                );
              }
            });
          },
          child: Text("Http DELETE"),
        ),
        Divider(),
        Expanded(child: SingleChildScrollView(child: Text(responseText))),
      ],
    );
  }
}
