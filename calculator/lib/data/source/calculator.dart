import '../data.dart';

class CalculatorDataSource {
  final ICalculatorLocalDataSource _localDataSource;

  CalculatorDataSource(this._localDataSource);

  Future<void> save(CalculatorModel model) {
    return _localDataSource.setString(model.result);
  }

  Future<CalculatorModel> fetch() async {
    final String value = await _localDataSource.getString() ?? '';
    final CalculatorModel model = CalculatorModel(result: value);
    return model;
  }
}
