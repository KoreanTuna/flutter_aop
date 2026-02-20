import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AopRegistry.instance.clear());

  group('@Around advice', () {
    test('proceed() executes original method and returns result', () async {
      var aroundCalled = false;
      var originalCalled = false;

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            aroundCalled = true;
            final result = await ctx.proceed();
            return result;
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'getData',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      final result = await runAsyncWithAop<int>(
        context: context,
        invoke: () {
          originalCalled = true;
          return 42;
        },
      );

      expect(aroundCalled, isTrue);
      expect(originalCalled, isTrue);
      expect(result, 42);
    });

    test('around can modify return value', () async {
      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            final result = await ctx.proceed();
            return (result as int) * 2;
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'calculate',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      final result = await runAsyncWithAop<int>(
        context: context,
        invoke: () => 21,
      );

      expect(result, 42);
    });

    test('around can skip original method entirely', () async {
      var originalCalled = false;

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            // Don't call proceed(), return cached value
            return 'cached';
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'fetch',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      final result = await runAsyncWithAop<String>(
        context: context,
        invoke: () {
          originalCalled = true;
          return 'original';
        },
      );

      expect(originalCalled, isFalse);
      expect(result, 'cached');
    });

    test('multiple around advices chain correctly', () async {
      final order = <String>[];

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            order.add('outer-before');
            final result = await ctx.proceed();
            order.add('outer-after');
            return result;
          },
        ),
        order: 1,
      );

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            order.add('inner-before');
            final result = await ctx.proceed();
            order.add('inner-after');
            return result;
          },
        ),
        order: 2,
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'process',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () => order.add('original'),
      );

      expect(order, [
        'outer-before',
        'inner-before',
        'original',
        'inner-after',
        'outer-after',
      ]);
    });

    test('around works with before/after hooks', () async {
      final order = <String>[];

      AopRegistry.instance.register(
        AopHooks(
          before: (ctx) => order.add('before'),
          after: (ctx) => order.add('after'),
          around: (ctx) async {
            order.add('around-before');
            final result = await ctx.proceed();
            order.add('around-after');
            return result;
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'run',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () => order.add('original'),
      );

      // Around wraps the entire before/original/after flow
      expect(order, [
        'around-before',
        'before',
        'original',
        'after',
        'around-after',
      ]);
    });

    test('sync around hook works with sync method', () {
      final order = <String>[];

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) {
            order.add('around-before');
            final result = ctx.proceed();
            order.add('around-after');
            return result;
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'syncMethod',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      final result = runSyncWithAop<int>(
        context: context,
        invoke: () {
          order.add('original');
          return 42;
        },
      );

      expect(result, 42);
      expect(order, ['around-before', 'original', 'around-after']);
    });

    test('async around hook on sync method throws StateError', () {
      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            return await ctx.proceed();
          },
        ),
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'syncMethod',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      expect(
        () => runSyncWithAop<int>(
          context: context,
          invoke: () => 42,
        ),
        throwsStateError,
      );
    });
  });
}
