import 'package:flutter_aop/flutter_aop.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'flutter_aop_bootstrap.g.dart';
import 'login_service.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  runFlutterAopBootstrap();
  getIt.init();
}

@module
abstract class ServiceModule {
  @lazySingleton
  LoginService loginService() => aopWrap(LoginService());
}
