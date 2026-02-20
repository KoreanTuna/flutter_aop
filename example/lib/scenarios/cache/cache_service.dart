// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'cache_service.aop.dart';

/// Scenario type: Read-heavy endpoint with cache optimization.
/// 시나리오 유형: 읽기 중심 엔드포인트의 캐시 최적화입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - This method is tagged with `cache`.
/// - 이 메서드는 `cache` 태그를 사용합니다.
/// - `CacheAspect` applies `@Around` advice to control proceed behavior.
/// - `CacheAspect`가 `@Around` advice로 proceed 동작을 제어합니다.
/// - The second call with the same arguments should bypass service logic.
/// - 동일 인자로 두 번째 호출 시 서비스 로직을 우회해야 합니다.
class CatalogService {
  /// Counter only for proving whether original service logic ran.
  /// 원본 서비스 로직이 실행됐는지 확인하기 위한 카운터입니다.
  int loadCount = 0;

  /// Simulates a remote fetch that we want to cache at the aspect layer.
  /// Aspect 레이어에서 캐시하고 싶은 원격 조회를 시뮬레이션합니다.
  @Aop(tag: 'cache', description: 'Load product list from remote source')
  Future<List<String>> loadProducts(String category) async {
    loadCount += 1;
    print(
      '[Service][Catalog] Fetching category="$category" (count=$loadCount)',
    );
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return <String>[
      '$category-item-a',
      '$category-item-b',
      'version-$loadCount',
    ];
  }
}
