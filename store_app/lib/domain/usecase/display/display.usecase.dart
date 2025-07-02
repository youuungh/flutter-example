import 'package:injectable/injectable.dart';
import '../../repository/display.repository.dart';
import '../base/usecase.dart';

@singleton
class DisplayUseCase {
  final DisplayRepository _displayRepository;

  DisplayUseCase(this._displayRepository);

  Future execute<T> ({required UseCase usecase}) async {
    return await usecase(_displayRepository);
  }
}