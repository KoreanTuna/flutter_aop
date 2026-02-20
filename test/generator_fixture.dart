import 'package:flutter_aop/flutter_aop.dart';

part 'generator_fixture.aop.dart';

class GeneratorPointcutService {
  @Aop(tag: 'audit')
  String findById(String id) => 'value:$id';

  @Aop(tag: 'other')
  String findOther(String id) => 'other:$id';
}

@Aspect(tag: 'audit')
class GeneratorPointcutAspect {
  const GeneratorPointcutAspect();

  static final List<String> calls = <String>[];

  static void reset() => calls.clear();

  @Before(
    pointcut: Pointcut(classPattern: '*Service', methodPattern: 'find*'),
  )
  void before(AopContext context) {
    calls.add('before ${context.methodName}');
  }
}

class GeneratorGenericService {
  @Aop(tag: 'generic')
  T echo<T extends Object>(T value) => value;
}

@Aspect(tag: 'generic')
class GeneratorGenericAspect {
  const GeneratorGenericAspect();

  static final List<String> calls = <String>[];

  static void reset() => calls.clear();

  @Before()
  void before(AopContext context) {
    calls.add('before ${context.methodName}');
  }
}
