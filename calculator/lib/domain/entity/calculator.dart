import '../../util/util.dart';

class CalculatorEntity {
  String _result;

  String get result => _result;

  CalculatorEntity({String? result}) : _result = result ?? '0';

  String _num1 = '0';
  String _num2 = '0';

  String _operator = '';

  String get operator => _operator;

  String get expression {
    if (_operator.isEmpty) return '';
    if (_isNewNumber && _num2 == '0') {
      return '$_num1 $_operator';
    }
    return '$_num1 $_operator $_num2';
  }

  bool _isNewNumber = false;

  void calculate(String buttonText) {
    switch (buttonText) {
      case 'C':
        _performClear();
      case '+/-':
        _performConvert();
      case '<':
        _performBackspace();
      case '+':
      case '-':
      case 'x':
      case '/':
        _performOperator(buttonText);
      case '=':
        _performCalculator();
      case '.':
        _performDecimalPoint();
      default:
        _performInputNumber(buttonText);
    }
  }

  void _performClear() {
    _result = '0';
    _num1 = '0';
    _num2 = '0';
    _operator = '';
    _isNewNumber = false;
  }

  void _performConvert() {
    if (_result == '0') return;
    if (_result.startsWith('-')) {
      _result = _result.replaceFirst('-', '');
    } else {
      _result = '-$_result';
    }
  }

  void _performBackspace() {
    if (_result.length > 2) {
      _result = _result.substring(0, _result.length - 1);
      return;
    }

    if (_result.startsWith('-')) {
      _result = '0';
      return;
    }

    if (_result.length > 1) {
      _result = _result.substring(0, _result.length - 1);
    } else {
      _result = '0';
    }
  }

  void _performOperator(String operator) {
    if (_operator.isNotEmpty && !_isNewNumber) {
      _performCalculator();
    }

    _num1 = _result;
    _operator = operator;
    _isNewNumber = true;
  }

  void _performCalculator() {
    if (_operator.isEmpty) return;

    final double number;
    switch (_operator) {
      case '+':
        number = double.parse(_num1) + double.parse(_num2);
      case '-':
        number = double.parse(_num1) - double.parse(_num2);
      case 'x':
        number = double.parse(_num1) * double.parse(_num2);
      case '/':
        number = double.parse(_num1) / double.parse(_num2);
      default:
        return;
    }

    final String result = IFormatter.normalize(number);
    _result = result;
    _num1 = result;
    _num2 = '0';
    _operator = '';
    _isNewNumber = false;
  }

  void _performDecimalPoint() {
    if (_result.contains('.')) return;
    _result = '$_result.';
  }

  void _performInputNumber(String number) {
    if (_isNewNumber) {
      _result = number;
      _num2 = number;
      _isNewNumber = false;
    } else {
      final String result = _result == '0' ? number : _result + number;
      _result = result;

      if (_operator.isNotEmpty) {
        _num2 = result;
      }
    }
  }
}
