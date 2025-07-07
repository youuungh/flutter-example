import '../../domain/domain.dart';
import '../data.dart';

class CalculatorRepository implements ICalculatorRepository {
  final CalculatorDataSource _calculatorDataSource;

  CalculatorRepository(this._calculatorDataSource);

  @override
  Future<CalculatorEntity> fetch() async {
    final CalculatorModel model = await _calculatorDataSource.fetch();
    return model.toEntity();
  }

  @override
  Future<void> save(CalculatorEntity entity) {
    return _calculatorDataSource.save(entity.toModel());
  }
}

extension on CalculatorModel {
  CalculatorEntity toEntity() {
    return CalculatorEntity(
      result: result,
    );
  }
}

extension on CalculatorEntity {
  CalculatorModel toModel() {
    return CalculatorModel(
      result: result,
    );
  }
}