// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'feature_flag_aspect.aop.dart';

/// Scenario type: Branch override using `skipWithResult`.
/// 시나리오 유형: `skipWithResult`를 이용한 분기 우회입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Uses `@Before` to intercept early.
/// - `@Before`로 초기 단계에서 인터셉트합니다.
/// - Returns an alternative route by calling `ctx.skipWithResult(...)`.
/// - `ctx.skipWithResult(...)`를 호출해 대체 라우트를 반환합니다.
/// - Prevents the original method from executing.
/// - 원본 메서드 실행을 차단합니다.
@Aspect(tag: 'feature-flag')
class FeatureFlagAspect {
  const FeatureFlagAspect();

  /// Forces legacy route when beta flag is considered disabled.
  /// 베타 플래그가 비활성으로 간주될 때 레거시 라우트를 강제합니다.
  @Before()
  void routeOverride(AopContext ctx) {
    print('[Aspect][FeatureFlag] beta disabled -> use legacy route');
    ctx.skipWithResult('/legacy-checkout');
  }
}
