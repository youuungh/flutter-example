import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency.config.dart';

final GetIt locator = GetIt.instance;

@InjectableInit()
void configureDependencies() => locator.init();