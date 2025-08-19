import 'package:add/add.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('EventBus Add'),
        actions: [
          IconButton(
            onPressed: () {
              Modular.get<EventBus>().fire(AddRouteEvent('/setting/detail'));
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Modular.to.pushNamed('/add/detail');
        },
      ),
    );
  }
}

class AddModule extends Module {
  AddModule();

  @override
  void routes(RouteManager r) {
    r.child('/add', child: (context) => AddScreen());
    r.child('/add/detail', child: (context) => AddDetailScreen());
  }
}

class AddRouteEvent {
  final String route;

  AddRouteEvent(this.route);
}
