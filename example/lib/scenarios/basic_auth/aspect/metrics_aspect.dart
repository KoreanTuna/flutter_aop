// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'metrics_aspect.aop.dart';

/// Scenario type: Lightweight latency metrics.
/// 시나리오 유형: 경량 지연 시간 메트릭 수집입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Bound to the `auth` tag.
/// - `auth` 태그에 바인딩됩니다.
/// - Uses before/after/onError advice.
/// - before/after/onError advice를 사용합니다.
/// - Stores per-invocation state in [AopContext] attributes instead of
///   global mutable maps keyed by method name.
/// - 메서드 이름 기반 전역 가변 맵 대신 [AopContext] attribute에
///   호출 단위 상태를 저장합니다.
@Aspect(tag: 'auth')
class MetricsAspect {
  const MetricsAspect();

  /// Attribute key for storing the per-call stopwatch.
  /// 호출별 스톱워치를 저장하기 위한 attribute 키입니다.
  static const _timerAttributeKey = 'metrics.timer';

  /// Starts timing just before the target method is invoked.
  /// 대상 메서드 호출 직전에 타이밍을 시작합니다.
  @Before()
  void startTimer(AopContext ctx) {
    ctx.setAttribute(_timerAttributeKey, Stopwatch()..start());
    print('[Metrics] Started timer for ${ctx.methodName}');
  }

  /// Stops timing on success and prints elapsed milliseconds.
  /// 성공 시 타이밍을 종료하고 경과 밀리초를 출력합니다.
  @After()
  void stopTimer(AopContext ctx) {
    final stopwatch = ctx.removeAttribute(_timerAttributeKey) as Stopwatch?;
    if (stopwatch != null) {
      stopwatch.stop();
    }
    print(
      '[Metrics] Stopped timer for ${ctx.methodName}. Elapsed time: ${stopwatch?.elapsedMilliseconds} ms',
    );
  }

  /// Ensures timing state is cleaned up when an error occurs.
  /// 에러 발생 시 타이밍 상태가 정리되도록 보장합니다.
  @OnError()
  void recordFailure(AopContext ctx) {
    (ctx.removeAttribute(_timerAttributeKey) as Stopwatch?)?.stop();
    print('[Metrics] Stopped timer for ${ctx.methodName} due to error');
  }
}
