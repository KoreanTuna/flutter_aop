// ignore_for_file: avoid_print

import 'package:flutter_aop/flutter_aop.dart';

part 'metrics_aspect.aop.dart';

@Aspect(tag: 'auth')
class MetricsAspect {
  const MetricsAspect();

  static final Map<String, Stopwatch> _timers = <String, Stopwatch>{};

  @Before()
  void startTimer(AopContext ctx) {
    _timers[ctx.methodName] = Stopwatch()..start();
    print('[Metrics] Started timer for ${ctx.methodName}');
  }

  @After()
  void stopTimer(AopContext ctx) {
    final stopwatch = _timers.remove(ctx.methodName);
    if (stopwatch != null) {
      stopwatch.stop();
    }
    print(
      '[Metrics] Stopped timer for ${ctx.methodName}. Elapsed time: ${stopwatch?.elapsedMilliseconds} ms',
    );
  }

  @OnError()
  void recordFailure(AopContext ctx) {
    _timers.remove(ctx.methodName)?.stop();
    print('[Metrics] Stopped timer for ${ctx.methodName} due to error');
  }
}
