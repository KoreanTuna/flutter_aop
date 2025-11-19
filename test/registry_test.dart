import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AopRegistry.instance.clear());

  test('global and tagged hooks execute in order', () {
    final calls = <String>[];
    AopRegistry.instance.register(
      AopHooks(
        before: (context) => calls.add('global-before ${context.methodName}'),
        onError: (context) => calls.add('global-error ${context.methodName}'),
      ),
    );
    AopRegistry.instance.register(
      AopHooks(
        before: (context) => calls.add('tag-before ${context.methodName}'),
        onError: (context) => calls.add('tag-error ${context.methodName}'),
      ),
      tag: 'checkout',
    );

    final context = AopContext(
      target: Object(),
      className: 'CheckoutService',
      methodName: 'placeOrder',
      annotation: const Aop(tag: 'checkout'),
      positionalArguments: const [],
      namedArguments: const {},
    );

    runSyncWithAop<void>(context: context, invoke: () {});
    expect(calls, ['global-before placeOrder', 'tag-before placeOrder']);
    calls.clear();

    expect(
      () => runSyncWithAop<void>(
        context: context,
        invoke: () => throw StateError('boom'),
      ),
      throwsStateError,
    );

    expect(calls, [
      'global-before placeOrder',
      'tag-before placeOrder',
      'global-error placeOrder',
      'tag-error placeOrder',
    ]);
  });

  test('clear removes every hook', () {
    AopRegistry.instance.register(AopHooks(before: (_) {}));
    AopRegistry.instance.register(AopHooks(before: (_) {}), tag: 'checkout');

    expect(AopRegistry.instance.resolve(null), isNotEmpty);

    AopRegistry.instance.clear();

    expect(AopRegistry.instance.resolve(null), isEmpty);
    expect(AopRegistry.instance.resolve('checkout'), isEmpty);
  });
}
