import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_test/freezed_user_model.dart';
import 'package:http/http.dart' as http;

String jsonUrl = "https://jsonplaceholder.typicode.com/users";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Hello')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final response = await http.get(
              Uri.parse(jsonUrl),
              headers: {
                'User-Agent': 'Flutter App',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              print(response.body);
              List<dynamic> jsonResp = jsonDecode(response.body);
              print(jsonResp);
              for (var element in jsonResp) {
                final jsonData = element as Map<String, dynamic>;
                final user = FreezedUserModel.fromJson(jsonData);
                print("$user");
              }
            } else {
              throw Exception('Failed to load user: ${response.statusCode}');
            }
          },
        ),
      ),
    );
  }
}
