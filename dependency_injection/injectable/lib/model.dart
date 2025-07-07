import 'package:injectable/injectable.dart';

enum CounterMode {
  plus,
  minus;

  CounterMode next() {
    switch (this) {
      case CounterMode.plus:
        return CounterMode.minus;
      case CounterMode.minus:
        return CounterMode.plus;
    }
  }
}

@singleton
class CounterModel {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
  }

  void decrement() {
    _counter--;
  }
}

@singleton
class CounterModeModel {
  CounterMode _counterMode = CounterMode.plus;

  CounterMode get counterMode => _counterMode;

  void toggleMode() {
    _counterMode = _counterMode.next();
  }
}