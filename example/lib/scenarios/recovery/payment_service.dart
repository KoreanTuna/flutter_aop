// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'payment_service.aop.dart';

/// Scenario type: Failure and fallback recovery.
/// 시나리오 유형: 실패 후 폴백 복구입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Tagged as `payment`.
/// - `payment` 태그를 사용합니다.
/// - Service intentionally throws.
/// - 서비스가 의도적으로 예외를 발생시킵니다.
/// - `PaymentRecoveryAspect` converts failure into a fallback response.
/// - `PaymentRecoveryAspect`가 실패를 폴백 응답으로 변환합니다.
class PaymentService {
  /// Simulates a failing network charge call.
  /// 실패하는 네트워크 결제 호출을 시뮬레이션합니다.
  @Aop(tag: 'payment')
  Future<String> charge(String userId) async {
    print('[Service][Payment] charging user="$userId"');
    throw StateError('Payment network timeout');
  }
}
