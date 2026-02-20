// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

import 'di.dart';
import 'scenarios/basic_auth/login_service.dart';
import 'scenarios/cache/cache_service.dart';
import 'scenarios/ordering/pipeline_service.dart';
import 'scenarios/pointcut/repository_service.dart';
import 'scenarios/recovery/payment_service.dart';
import 'scenarios/short_circuit/feature_flag_service.dart';

/// Entry point that executes all scenario samples in sequence.
/// 모든 시나리오 샘플을 순차 실행하는 진입점입니다.
///
/// This file is intentionally orchestration-only so each scenario can keep
/// domain logic and aspect logic isolated in its own folder.
/// 이 파일은 오케스트레이션만 담당하여 각 시나리오 폴더가
/// 도메인 로직과 Aspect 로직을 분리해 유지하도록 구성했습니다.
Future<void> main() async {
  await configureDependencies();
  await runAllScenarios();
}

/// Runs every scenario to show different AOP patterns side by side.
/// 서로 다른 AOP 패턴을 나란히 확인할 수 있도록 모든 시나리오를 실행합니다.
Future<void> runAllScenarios() async {
  _printHeader('Scenario 1: Basic before/after/onError hooks (auth)');
  await _scenarioBasicHooks();

  _printHeader('Scenario 2: Around cache (cache tag)');
  await _scenarioAroundCache();

  _printHeader('Scenario 3: Pointcut matching (*Repository + find*)');
  await _scenarioPointcut();

  // _printHeader('Scenario 4: Ordered aspects (order: 1 -> 3)');
  // await _scenarioOrdering();

  // _printHeader('Scenario 5: OnError recovery + after');
  // await _scenarioRecovery();

  // _printHeader('Scenario 6: skipWithResult short-circuit');
  // await _scenarioSkipWithResult();

  _printHeader('Done');
}

/// Scenario 1:
/// 시나리오 1:
/// Tag-based before/after/onError flow on an auth service.
/// 인증 서비스에 태그 기반 before/after/onError 흐름을 적용합니다.
Future<void> _scenarioBasicHooks() async {
  final service = getIt<LoginService>();

  await service.login('gmail', 'gmail!');

  try {
    await service.loginWithFailure('gmail');
  } catch (error) {
    print('[Main] expected error captured: $error');
  }
}

/// Scenario 2:
/// 시나리오 2:
/// Around advice with cache hit/miss behavior.
/// 캐시 히트/미스 동작을 Around advice로 구현합니다.
Future<void> _scenarioAroundCache() async {
  final catalog = aopWrap(CatalogService());

  final first = await catalog.loadProducts('popular');
  final second = await catalog.loadProducts('popular');

  print('[Main] first  = $first');
  print('[Main] second = $second');
}

/// Scenario 3:
/// 시나리오 3:
/// Pointcut matching by class/method patterns.
/// 클래스/메서드 패턴 기반의 포인트컷 매칭을 보여줍니다.
Future<void> _scenarioPointcut() async {
  final users = aopWrap(UserRepository());
  final orders = aopWrap(OrderRepository());

  await users.findUserById(10);
  await users.saveUser('Alice');
  await orders.findOrderById(9001);
}

/// Scenario 4:
/// 시나리오 4:
/// Deterministic execution order across multiple aspects.
/// 여러 Aspect 간 결정적 실행 순서를 보여줍니다.
Future<void> _scenarioOrdering() async {
  final pipeline = aopWrap(PipelineService());
  final result = await pipeline.process('order-123');
  print('[Main] pipeline result=$result');
}

/// Scenario 5:
/// 시나리오 5:
/// Recovery in onError followed by after advice.
/// onError 복구 이후 after advice가 이어서 실행되는 흐름입니다.
Future<void> _scenarioRecovery() async {
  final payment = aopWrap(PaymentService());
  final result = await payment.charge('user-1');
  print('[Main] payment result=$result');
}

/// Scenario 6:
/// 시나리오 6:
/// Skip original method execution with skipWithResult.
/// skipWithResult로 원본 메서드 실행을 건너뜁니다.
Future<void> _scenarioSkipWithResult() async {
  final flags = aopWrap(FeatureFlagService());
  final route = flags.checkoutRoute();
  print('[Main] checkout route=$route');
}

/// Simple separator for console readability.
/// 콘솔 가독성을 위한 간단한 구분선입니다.
void _printHeader(String title) {
  print('\n============================================================');
  print(title);
  print('============================================================');
}
