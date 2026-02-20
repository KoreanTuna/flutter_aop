// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'cache_aspect.aop.dart';

/// Scenario type: Around advice for cache orchestration.
/// 시나리오 유형: 캐시 오케스트레이션을 위한 Around advice입니다.
///
/// AOP usage:
/// AOP 활용 방식:
/// - Attached to the `cache` tag.
/// - `cache` 태그에 연결됩니다.
/// - Uses `@Around` to decide whether to call `ctx.proceed()`.
/// - `@Around`를 사용해 `ctx.proceed()` 호출 여부를 결정합니다.
/// - Demonstrates complete interception control with a cache hit/miss flow.
/// - 캐시 히트/미스 흐름으로 완전한 인터셉션 제어를 보여줍니다.
@Aspect(tag: 'cache')
class CacheAspect {
  const CacheAspect();

  /// In-memory cache for demonstration purposes.
  /// 데모 목적의 인메모리 캐시입니다.
  static final Map<String, dynamic> _cache = <String, dynamic>{};

  /// Returns cached data on hit, otherwise executes and stores result.
  /// 히트 시 캐시 데이터를 반환하고, 아니면 실행 후 결과를 저장합니다.
  @Around()
  Future<dynamic> cache(AopContext ctx) async {
    final key = '${ctx.methodName}:${ctx.positionalArguments.join('|')}';
    if (_cache.containsKey(key)) {
      print('[Aspect][Cache] HIT key=$key');
      return _cache[key];
    }

    print('[Aspect][Cache] MISS key=$key');
    final result = await ctx.proceed();
    _cache[key] = result;
    return result;
  }
}
