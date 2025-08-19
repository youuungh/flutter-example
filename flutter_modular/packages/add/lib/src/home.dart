import 'package:add/add.dart';
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
        title: const Text('FlutterModular Add'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
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
