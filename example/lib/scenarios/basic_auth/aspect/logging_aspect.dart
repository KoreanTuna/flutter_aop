// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'logging_aspect.aop.dart';

/// Scenario type: Operational logging.
/// 시나리오 유형: 운영 로그 수집입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Bound to the `auth` tag.
/// - `auth` 태그에 바인딩됩니다.
/// - Emits logs at before/after/onError checkpoints.
/// - before/after/onError 체크포인트에서 로그를 출력합니다.
/// - Keeps service code focused on business logic.
/// - 서비스 코드는 비즈니스 로직에 집중하도록 유지합니다.
@Aspect(tag: 'auth')
class LoggingAspect {
  const LoggingAspect();

  /// Logs method name and inputs before invocation.
  /// 호출 전에 메서드 이름과 입력값을 기록합니다.
  @Before()
  void logBefore(AopContext ctx) {
    print('[Aspect][before] ${ctx.methodName} -> ${ctx.positionalArguments}');
  }

  /// Logs method result after successful invocation.
  /// 호출 성공 후 메서드 결과를 기록합니다.
  @After()
  void logAfter(AopContext ctx) {
    print('[Aspect][after] ${ctx.methodName} -> result=${ctx.result}');
  }

  /// Logs the captured error when invocation fails.
  /// 호출 실패 시 수집된 에러를 기록합니다.
  @OnError()
  void logError(AopContext ctx) {
    print('[Aspect][error] ${ctx.methodName} -> ${ctx.error}');
  }
}
