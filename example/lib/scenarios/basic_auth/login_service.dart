// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'login_service.aop.dart';

/// Scenario type: Basic cross-cutting hooks around an auth use case.
/// 시나리오 유형: 인증 유스케이스에 기본 횡단 훅을 적용합니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Both methods are tagged with `auth`.
/// - 두 메서드는 모두 `auth` 태그를 사용합니다.
/// - `LoggingAspect` and `MetricsAspect` subscribe to this tag.
/// - `LoggingAspect`와 `MetricsAspect`가 이 태그를 구독합니다.
/// - The success path triggers before -> after.
/// - 성공 경로에서는 before -> after가 실행됩니다.
/// - The failure path triggers before -> onError.
/// - 실패 경로에서는 before -> onError가 실행됩니다.
class LoginService {
  /// Success case used to demonstrate before/after advice.
  /// before/after advice를 보여주기 위한 성공 케이스입니다.
  @Aop(
    tag: 'auth',
    description: 'Authenticate the user against a remote server',
  )
  Future<void> login(String id, String password) async {
    print('[Service] Starting login for $id');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    print('[Service] Login successful for $id');
  }

  /// Failure case used to demonstrate onError advice dispatch.
  /// onError advice 디스패치를 보여주기 위한 실패 케이스입니다.
  @Aop(tag: 'auth', description: 'Failing authentication sample')
  Future<void> loginWithFailure(String id) async {
    print('[Service] Starting failing login for $id');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    throw StateError('Invalid credentials for $id');
  }
}
