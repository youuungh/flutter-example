import '../../../../core/utils/constant.dart';
import '../../../../core/utils/error/error_response.dart';
import '../../../../core/utils/extensions.dart';
import '../../../model/common/result/result.dart';
import '../../../model/display/menu/menu.model.dart';
import '../../../repository/display.repository.dart';
import '../../base/remote.usecase.dart';

class GetMenusUseCase extends RemoteUseCase<DisplayRepository> {
  final MallType mallType;

  GetMenusUseCase({required this.mallType});

  @override
  Future<Result<List<Menu>>> call(DisplayRepository repository) async {
    final result = await repository.getMenusByMallType(mallType: mallType);

    return (result.status.isSuccess)
        ? Result.Success(result.data ?? [])
        : Result.Failure(
      ErrorResponse(
        status: result.status,
        code: result.code,
        message: result.message,
      ),
    );
  }
}
