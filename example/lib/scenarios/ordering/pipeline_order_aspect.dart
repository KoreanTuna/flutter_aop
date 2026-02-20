// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'pipeline_order_aspect.aop.dart';

/// Scenario type: Order-based advice composition.
/// 시나리오 유형: order 기반 advice 조합입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - All aspects target `pipeline` tag.
/// - 모든 Aspect가 `pipeline` 태그를 대상으로 합니다.
/// - Lower `order` runs first.
/// - 더 낮은 `order`가 먼저 실행됩니다.
/// - This simulates layered policies (security -> validation -> audit).
/// - 계층형 정책(보안 -> 검증 -> 감사)을 시뮬레이션합니다.
@Aspect(tag: 'pipeline', order: 1)
class SecurityAspect {
  const SecurityAspect();

  /// Runs first.
  /// 첫 번째로 실행됩니다.
  @Before()
  void before(AopContext ctx) {
    print('[Aspect][Order:1][Security] ${ctx.methodName}');
  }
}

@Aspect(tag: 'pipeline', order: 2)
class ValidationAspect {
  const ValidationAspect();

  /// Runs second.
  /// 두 번째로 실행됩니다.
  @Before()
  void before(AopContext ctx) {
    print('[Aspect][Order:2][Validation] ${ctx.methodName}');
  }
}

@Aspect(tag: 'pipeline', order: 3)
class AuditAspect {
  const AuditAspect();

  /// Runs third.
  /// 세 번째로 실행됩니다.
  @Before()
  void before(AopContext ctx) {
    print('[Aspect][Order:3][Audit] ${ctx.methodName}');
  }
}
