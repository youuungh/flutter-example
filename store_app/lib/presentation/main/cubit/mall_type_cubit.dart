import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/custom/custom_app_bar.dart';
import '../../../core/utils/constant.dart';


class MallTypeCubit extends Cubit<MallType> {
  MallTypeCubit() : super(MallType.store);

  void changeMallType(int index) => emit(MallType.values[index]);
}

extension MallTypeX on MallType {
  String get toName {
    switch (this) {
      case MallType.store:
        return '스토어';
      case MallType.beauty:
        return '뷰티';
    }
  }

  CustomAppBarTheme get theme {
    switch (this) {
      case MallType.store:
        return CustomAppBarTheme.store;
      case MallType.beauty:
        return CustomAppBarTheme.beauty;
    }
  }

  bool get isStore => this == MallType.store;
  bool get isBeauty => this == MallType.beauty;
}