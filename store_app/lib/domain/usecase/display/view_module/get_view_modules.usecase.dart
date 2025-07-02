import '../../../../core/utils/error/error_response.dart';
import '../../../../core/utils/extensions.dart';
import '../../../model/common/result/result.dart';
import '../../../model/display/view_module/view_module.model.dart';
import '../../../repository/display.repository.dart';
import '../../base/remote.usecase.dart';

class GetViewModulesUsecase extends RemoteUseCase<DisplayRepository> {
  final int tabId;
  final int page;
  final bool isRefresh;

  GetViewModulesUsecase({
    required this.tabId,
    this.page = 1,
    required this.isRefresh,
  });

  @override
  Future<Result<List<ViewModule>>> call(DisplayRepository repository) async {
    final result = await repository.getViewModulesByTabId(
      tabId: tabId,
      page: page,
      isRefresh: isRefresh,
    );

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
