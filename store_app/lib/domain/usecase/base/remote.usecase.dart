import '../../repository/repository.dart';
import 'usecase.dart';

abstract class RemoteUseCase<T extends Repository> extends UseCase<T> {}