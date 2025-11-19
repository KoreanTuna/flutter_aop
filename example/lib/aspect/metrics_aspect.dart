import 'package:flutter_aop/flutter_aop.dart';

part 'metrics_aspect.aop.dart';

@Aspect(tag: 'auth')
class MetricsAspect {
  const MetricsAspect();

  static final Map<String, Stopwatch> _timers = <String, Stopwatch>{};

  @Before()
  void startTimer(AopContext ctx) {
    _timers[ctx.methodName] = Stopwatch()..start();
  }

  @After()
  void stopTimer(AopContext ctx) {
    final stopwatch = _timers.remove(ctx.methodName);
    if (stopwatch != null) {
      stopwatch.stop();
      print(
        '[Aspect][metrics] ${ctx.methodName} took '
        '${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }

  @OnError()
  void recordFailure(AopContext ctx) {
    _timers.remove(ctx.methodName)?.stop();
    print('[Aspect][metrics] failure captured -> ${ctx.error}');
  }
}
