// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'pipeline_service.aop.dart';

/// Scenario type: Ordered policy pipeline.
/// 시나리오 유형: 순차 정책 파이프라인입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Tagged as `pipeline`.
/// - `pipeline` 태그를 사용합니다.
/// - Three aspects with different `order` values run before this method.
/// - 서로 다른 `order`를 가진 세 Aspect가 메서드 실행 전에 동작합니다.
class PipelineService {
  /// Target method that receives ordered before advice chain.
  /// 순서가 있는 before advice 체인을 받는 대상 메서드입니다.
  @Aop(tag: 'pipeline')
  Future<String> process(String payload) async {
    print('[Service][Pipeline] processing payload="$payload"');
    return 'processed-$payload';
  }
}
