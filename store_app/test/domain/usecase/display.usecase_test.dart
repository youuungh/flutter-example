import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store_app/core/utils/constant.dart';
import 'package:store_app/core/utils/error/error_response.dart';
import 'package:store_app/data/data_source/local_storage/display.dao.dart';
import 'package:store_app/data/data_source/remote/display/display.api.dart';
import 'package:store_app/data/repository_impl/display.repository_impl.dart';
import 'package:store_app/domain/model/common/result/result.dart';
import 'package:store_app/domain/model/display/menu/menu.model.dart';
import 'package:store_app/domain/repository/display.repository.dart';
import 'package:store_app/domain/usecase/display/display.usecase.dart';
import 'package:store_app/domain/usecase/display/menu/get_menus.usecase.dart';

class MockDisplayApi extends Mock implements DisplayApi {}

class MockDisplayRepository extends Mock implements DisplayRepository {}

class MockGetMenusUseCase extends Mock implements GetMenusUseCase {}

void main() {
  late DisplayRepository displayRepository;
  late DisplayUseCase displayUseCase;

  setUpAll(() {
    displayRepository = DisplayRepositoryImpl(MockDisplayApi(), DisplayDao());
    displayUseCase = DisplayUseCase(displayRepository);
  });

  test('DI successful', () => expect(displayUseCase, isNotNull));

  test('Get menu list successful', () async {
    final result = Result.Success([Menu(tabId: -1, title: '메뉴 테스트')]);
    final usecase = MockGetMenusUseCase();

    when(() => usecase.mallType).thenReturn(MallType.store);
    when(() => usecase.call(displayRepository)).thenAnswer((_) async => result);

    final actual = await displayUseCase.execute(usecase: usecase);
    
    expect(actual, result);
  });

  test('Get menu list failed', () async {
    final result = Result<List<Menu>>.Failure(ErrorResponse(status: 'error'));
    final usecase = MockGetMenusUseCase();

    when(() => usecase.mallType).thenReturn(MallType.store);
    when(() => usecase.call(displayRepository)).thenAnswer((_) async => result);

    final actual = await displayUseCase.execute(usecase: usecase);

    expect(actual, result);
  });
}
