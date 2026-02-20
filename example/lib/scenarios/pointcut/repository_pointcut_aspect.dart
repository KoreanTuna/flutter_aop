// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'repository_pointcut_aspect.aop.dart';

/// Scenario type: Declarative pointcut matching.
/// 시나리오 유형: 선언적 포인트컷 매칭입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Uses `@Before(pointcut: ...)` instead of relying on tag-only matching.
/// - 태그 기반 매칭에만 의존하지 않고 `@Before(pointcut: ...)`를 사용합니다.
/// - Targets all repository finder methods with one rule.
/// - 하나의 규칙으로 모든 repository 조회 메서드를 대상으로 합니다.
@Aspect()
class RepositoryPointcutAspect {
  const RepositoryPointcutAspect();

  /// Fires only when class/method patterns match.
  /// 클래스/메서드 패턴이 매칭될 때만 실행됩니다.
  @Before(
    pointcut: Pointcut(classPattern: '*Repository', methodPattern: 'find*'),
  )
  void beforeFind(AopContext ctx) {
    print('[Aspect][Pointcut] matched ${ctx.joinPointDescription}');
  }
}
