import 'package:shared_preferences/shared_preferences.dart';

abstract class ICalculatorLocalDataSource {
  String get key;

  Future<void> setString(String value);

  Future<String?> getString();
}

class CalculatorLocalDataSource implements ICalculatorLocalDataSource {
  @override
  String get key => 'calculator';

  @override
  Future<void> setString(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}