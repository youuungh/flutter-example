import 'package:add/add.dart';
import 'package:flutter/material.dart';

class SettingDetailScreen extends StatelessWidget {
  const SettingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Melos SettingDetail'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
