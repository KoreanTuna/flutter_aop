// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'flutter_aop_bootstrap.g.dart';
import 'scenarios/basic_auth/login_service.dart';

final GetIt getIt = GetIt.instance;

/// Configures DI and global runtime hooks for all scenario samples.
/// 모든 시나리오 샘플을 위한 DI와 전역 런타임 훅을 설정합니다.
///
/// AOP usage here is global:
/// 여기서의 AOP 사용 범위는 전역입니다:
/// - `runFlutterAopBootstrap()` registers all generated proxies/aspects.
/// - `runFlutterAopBootstrap()`이 생성된 프록시/Aspect를 모두 등록합니다.
/// - `createObservationHooks(...)` adds a cross-cutting observation pipeline
///   without modifying scenario service code.
/// - `createObservationHooks(...)`는 시나리오 서비스 코드를 수정하지 않고
///   횡단 관심사 관측 파이프라인을 추가합니다.
@InjectableInit()
Future<void> configureDependencies() async {
  runFlutterAopBootstrap();

  // Global observability hook:
  // 전역 관측성 훅:
  // captures invocation id, timing, args/result/error for every AOP call.
  // 모든 AOP 호출의 invocation id, 시간, 인자/결과/에러를 수집합니다.
  AopRegistry.instance.register(
    createObservationHooks(
      sink: (event) {
        final details = StringBuffer()
          ..write('[Obs][${event.phase.name}] ')
          ..write('#${event.invocationId} ')
          ..write('${event.joinPointDescription} ')
          ..write('elapsed=${event.elapsed.inMilliseconds}ms ')
          ..write('slow=${event.isSlow}');

        if (event.positionalArguments != null) {
          details.write(' args=${event.positionalArguments}');
        }
        if (event.result != null) {
          details.write(' result=${event.result}');
        }
        if (event.error != null) {
          details.write(' error=${event.error}');
        }

        print(details.toString());
      },
      includeArguments: true,
      includeResult: true,
      includeStackTrace: false,
      slowCallThreshold: const Duration(milliseconds: 200),
    ),
    order: -100,
  );

  getIt.init();
}

@module
abstract class ServiceModule {
  // Basic auth scenario is resolved through DI to show real-world wiring.
  // 기본 인증 시나리오를 DI로 해석해 실무형 와이어링을 보여줍니다.
  @lazySingleton
  LoginService loginService() => aopWrap(LoginService());
}
