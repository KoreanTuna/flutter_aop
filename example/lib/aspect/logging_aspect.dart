import 'package:flutter_aop/flutter_aop.dart';

part 'logging_aspect.aop.dart';

@Aspect(tag: 'auth')
class LoggingAspect {
  const LoggingAspect();

  @Before()
  void logBefore(AopContext ctx) {
    print('[Aspect][before] ${ctx.methodName} -> ${ctx.positionalArguments}');
  }

  @After()
  void logAfter(AopContext ctx) {
    print('[Aspect][after] ${ctx.methodName} -> result=${ctx.result}');
  }

  @OnError()
  void logError(AopContext ctx) {
    print('[Aspect][error] ${ctx.methodName} -> ${ctx.error}');
  }
}
