import 'package:flutter/material.dart';
import 'package:setting/setting.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Melos Setting'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingDetailScreen(),
            ),
          );
        },
      ),
    );
  }
}
