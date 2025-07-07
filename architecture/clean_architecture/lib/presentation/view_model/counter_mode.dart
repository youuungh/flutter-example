import 'package:flutter/material.dart';

import '../../domain/domain.dart';

class CounterModeViewModel {
  final CounterModeModel _counterModeModel;

  CounterModeViewModel(this._counterModeModel);

  final ValueNotifier<CounterMode> _counterMode = ValueNotifier<CounterMode>(CounterMode.plus);

  ValueNotifier<CounterMode> get counterMode => _counterMode;

  void toggleMode() {
    _counterModeModel.toggleMode();
    _update();
  }

  void _update() {
    _counterMode.value = _counterModeModel.counterMode;
  }
}