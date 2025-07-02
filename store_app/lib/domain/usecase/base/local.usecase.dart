import '../../repository/repository.dart';
import 'usecase.dart';

abstract class LocalUseCase<T extends Repository> extends UseCase<T> {}