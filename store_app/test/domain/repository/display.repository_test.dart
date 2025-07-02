import 'package:store_app/core/utils/constant.dart';
import 'package:store_app/data/data_source/local_storage/display.dao.dart';
import 'package:store_app/data/data_source/mock/display/display_mock_api.dart';
import 'package:store_app/data/data_source/remote/display/display.api.dart';
import 'package:store_app/data/dto/common/response_wrapper/response_wrapper.dart';
import 'package:store_app/data/dto/display/menu/menu.dto.dart';
import 'package:store_app/data/mapper/common.mapper.dart';
import 'package:store_app/data/mapper/display.mapper.dart';
import 'package:store_app/data/repository_impl/display.repository_impl.dart';
import 'package:store_app/domain/model/display/menu/menu.model.dart';
import 'package:store_app/domain/repository/display.repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDisplayApi extends Mock implements DisplayApi {}

void main() {
  late DisplayRepository displayRepository;
  late DisplayApi displayApi;

  setUpAll(() {
    displayApi = MockDisplayApi();
    displayRepository = DisplayRepositoryImpl(displayApi, DisplayDao());
  });

  test('DI and constructor test', () {
    expect(displayRepository, isNotNull);
  });

  group('메뉴 리스트 불러오기', () {
    // api 호출 성공
    test('API call completed', () async {
      try {
        await displayRepository.getMenusByMallType(mallType: MallType.store);
      } catch (_) {}
      verify(() => displayApi.getMenusByMallType(any())).called(1);
    });
    test('API call failed', () async {
      final exception = Exception('error');
      when(() => displayApi.getMenusByMallType(any())).thenThrow(exception);
      expect(
        () => displayRepository.getMenusByMallType(mallType: MallType.store),
        throwsA(exception),
      );
    });
    test('API fetched successfully', () async {
      final MallType mallType = MallType.store;
      final ResponseWrapper<List<MenuDto>> mockData = await DisplayMockApi()
          .getMenusByMallType(mallType.name);

      when(
        () => displayApi.getMenusByMallType(any()),
      ).thenAnswer((_) async => mockData);

      final actual = await displayRepository.getMenusByMallType(
        mallType: mallType,
      );
      final expected = mockData.toModel<List<Menu>>(
        mockData.data?.map((menuDto) => menuDto.toModel()).toList() ?? [],
      );
      expect(actual, expected);
    });
  });
}
