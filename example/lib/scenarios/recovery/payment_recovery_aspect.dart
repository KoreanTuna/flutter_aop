// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'payment_recovery_aspect.aop.dart';

/// Scenario type: Error recovery with `@OnError`.
/// 시나리오 유형: `@OnError` 기반 에러 복구입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Handles thrown error in `@OnError`.
/// - `@OnError`에서 발생한 에러를 처리합니다.
/// - Clears `ctx.error` to mark recovery.
/// - 복구 완료를 표시하기 위해 `ctx.error`를 비웁니다.
/// - Provides fallback via `ctx.result`.
/// - `ctx.result`를 통해 폴백 결과를 제공합니다.
/// - `@After` still runs after successful recovery.
/// - 복구 성공 이후에도 `@After`가 실행됩니다.
@Aspect(tag: 'payment')
class PaymentRecoveryAspect {
  const PaymentRecoveryAspect();

  /// Translates a transport failure into a retryable fallback result.
  /// 전송 계층 실패를 재시도 가능한 폴백 결과로 변환합니다.
  @OnError()
  void recover(AopContext ctx) {
    print('[Aspect][Recovery] recovered from error: ${ctx.error}');
    ctx.error = null;
    ctx.result = 'PENDING_RETRY';
  }

  /// Runs after recovery and prints the final outgoing value.
  /// 복구 후 실행되며 최종 반환 값을 출력합니다.
  @After()
  void after(AopContext ctx) {
    print('[Aspect][Recovery] final result=${ctx.result}');
  }
}
