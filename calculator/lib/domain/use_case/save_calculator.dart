import '../../util/util.dart';
import '../domain.dart';

class SaveCalculatorUseCase implements IUseCase<void, SaveCalculatorParams> {
  final ICalculatorRepository _calculatorRepository;

  SaveCalculatorUseCase(this._calculatorRepository);

  @override
  Future<void> execute([SaveCalculatorParams? params]) async {
    if (params == null) return;
    await _calculatorRepository.save(params.entity);
  }
}

class SaveCalculatorParams {
  final CalculatorEntity entity;

  SaveCalculatorParams({
    required this.entity,
  });
}