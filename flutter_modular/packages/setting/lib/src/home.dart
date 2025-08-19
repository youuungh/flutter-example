import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:setting/setting.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FlutterModular Setting'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Modular.to.pushNamed('/setting/detail');
        },
      ),
    );
  }
}

class SettingModule extends Module {
  SettingModule();

  @override
  void routes(RouteManager r) {
    r.child(
      '/setting',
      child: (context) => SettingScreen(),
    );
    r.child(
      '/setting/detail',
      child: (context) => SettingDetailScreen(),
    );
  }
}
