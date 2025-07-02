import 'package:injectable/injectable.dart';

import '../../repository/user.repository.dart';
import '../base/remote.usecase.dart';

@singleton
class UserUseCase {
  final UserRepository _userRepository;

  UserUseCase(this._userRepository);

  Future<T> execute<T>({required RemoteUseCase usecase}) async {
    return await usecase(_userRepository);
  }
}