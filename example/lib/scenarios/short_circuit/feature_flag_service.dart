// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'feature_flag_service.aop.dart';

/// Scenario type: Policy-driven short-circuiting.
/// 시나리오 유형: 정책 기반 단락(short-circuit) 처리입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Method is tagged with `feature-flag`.
/// - 메서드는 `feature-flag` 태그를 사용합니다.
/// - `FeatureFlagAspect` can skip original method execution.
/// - `FeatureFlagAspect`가 원본 메서드 실행을 건너뛸 수 있습니다.
class FeatureFlagService {
  /// Represents business logic that would run without short-circuit advice.
  /// 단락 advice가 없을 때 실행될 비즈니스 로직을 나타냅니다.
  @Aop(tag: 'feature-flag')
  String checkoutRoute() {
    print('[Service][FeatureFlag] new checkout route selected');
    return '/new-checkout';
  }
}
