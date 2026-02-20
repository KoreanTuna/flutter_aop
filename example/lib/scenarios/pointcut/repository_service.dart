// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'repository_service.aop.dart';

/// Scenario type: Pattern-based selection using pointcuts.
/// 시나리오 유형: 포인트컷 기반 패턴 선택입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Methods are annotated with `@Aop`.
/// - 메서드에 `@Aop`가 선언되어 있습니다.
/// - `RepositoryPointcutAspect` matches only `find*` methods in `*Repository`
///   classes, regardless of explicit tag wiring.
/// - `RepositoryPointcutAspect`는 명시적 태그 연결과 무관하게
///   `*Repository` 클래스의 `find*` 메서드만 매칭합니다.
class UserRepository {
  /// Should match pointcut (`UserRepository.find*`).
  /// 포인트컷과 매칭되어야 합니다 (`UserRepository.find*`).
  @Aop(tag: 'repo')
  Future<String> findUserById(int id) async {
    print('[Service][UserRepository] findUserById($id)');
    return 'user-$id';
  }

  /// Should NOT match pointcut (`save*` does not match `find*` pattern).
  /// 포인트컷과 매칭되면 안 됩니다 (`save*`는 `find*`와 불일치).
  @Aop(tag: 'repo')
  Future<void> saveUser(String name) async {
    print('[Service][UserRepository] saveUser($name)');
  }
}

class OrderRepository {
  /// Should match pointcut (`OrderRepository.find*`).
  /// 포인트컷과 매칭되어야 합니다 (`OrderRepository.find*`).
  @Aop(tag: 'repo')
  Future<String> findOrderById(int id) async {
    print('[Service][OrderRepository] findOrderById($id)');
    return 'order-$id';
  }
}
