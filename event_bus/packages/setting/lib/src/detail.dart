import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:setting/setting.dart';

class SettingDetailScreen extends StatelessWidget {
  const SettingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EventBus SettingDetail'),
        actions: [
          IconButton(
            onPressed: () {
              Modular.get<EventBus>().fire( SettingRouteEvent('/add'));
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
