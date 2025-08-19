import 'package:add/add.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddDetailScreen extends StatelessWidget {
  const AddDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EventBus AddDetail'),
        actions: [
          IconButton(
            onPressed: () {
              Modular.get<EventBus>().fire(AddRouteEvent('/setting'));
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
