import 'package:flutter/material.dart';
import 'package:server_communication_examples/dio_widget.dart';
import 'package:server_communication_examples/retrofit/retrofit_widget.dart';

const String api = "https://jsonplaceholder.typicode.com/posts";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RetrofitWidget(),
        ),
      ),
    );
  }
}
