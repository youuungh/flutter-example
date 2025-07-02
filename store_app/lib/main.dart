import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/theme/theme_data.dart';
import 'core/utils/constant.dart';
import 'data/entity/display/display.entity.dart';
import 'data/entity/display/target_api/target_api.dart';
import 'data/entity/display/view_module/view_module.entity.dart';
import 'data/entity/display/view_module_list/view_module_list.entity.dart';
import 'di.dart';
import 'presentation/main/bloc/cart_bloc/cart_bloc.dart';
import 'presentation/main/bloc/payment_bloc/payment_bloc.dart';
import 'presentation/main/bloc/user_bloc/user_bloc.dart';
import 'presentation/pages/cart_list/bloc/cart_list_bloc/cart_list_bloc.dart';
import 'presentation/routes/routes.dart';

void main(name, options) async {
  WidgetsFlutterBinding.ensureInitialized();

  String envFile = const String.fromEnvironment('FLAVOR') == 'prod'
      ? 'assets/env/.env'
      : 'assets/env/.env.dev';

  await dotenv.load(fileName: envFile);

  // Hive 초기화
  await Hive.initFlutter();

  // Hive object adapter
  Hive.registerAdapter(TargetApiAdapter());
  Hive.registerAdapter(ProductInfoEntityAdapter());
  Hive.registerAdapter(CartEntityAdapter());
  Hive.registerAdapter(ViewModuleEntityAdapter());
  Hive.registerAdapter(ViewModuleListEntityAdapter());

  await TargetApiValue().setTargetApi();

  configureDependencies();

  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  await Firebase.initializeApp(name: name, options: options);

  if (await dotenv.env['FLAVOR'] == 'prod') {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      return true;
    };
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<UserBloc>()..add(UserLoginWithToken()),
        ),
        BlocProvider(create: (_) => getIt<CartBloc>()..add(CartInitialized())),
        BlocProvider(
          create: (_) => getIt<CartListBloc>()..add(CartListInitialized()),
          lazy: false,
        ),
        BlocProvider(create: (_) => getIt<PaymentBloc>()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: CustomThemeData.themeData,
        debugShowCheckedModeBanner: dotenv.env['FLAVOR'] == 'dev',
      ),
    );
  }
}

class TargetApiValue {
  TargetApi? targetApi = TargetApi.REMOTE;

  static final TargetApiValue _instance = TargetApiValue._internal();

  bool get isRemoteApi => targetApi == TargetApi.REMOTE;

  factory TargetApiValue() => _instance;

  TargetApiValue._internal();

  Future<void> setTargetApi() async {
    var localStorage = await Hive.openBox<TargetApi>(Constants.targetApiKey);

    targetApi = localStorage.get(
      Constants.targetApiKey,
      defaultValue: TargetApi.REMOTE,
    );
  }
}
