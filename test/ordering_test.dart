import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AopRegistry.instance.clear());

  group('Hook ordering', () {
    test('hooks execute in order based on order parameter', () async {
      final calls = <String>[];

      // Register in reverse order to test that order parameter works
      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('third')),
        order: 3,
      );

      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('first')),
        order: 1,
      );

      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('second')),
        order: 2,
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'test',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(context: context, invoke: () {});

      expect(calls, ['first', 'second', 'third']);
    });

    test('hooks with same order execute in registration order', () async {
      final calls = <String>[];

      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('first')),
        order: 1,
      );

      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('second')),
        order: 1,
      );

      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('third')),
        order: 1,
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'test',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(context: context, invoke: () {});

      expect(calls, ['first', 'second', 'third']);
    });

    test('global hooks and tagged hooks are both sorted by order', () async {
      final calls = <String>[];

      // Global with high order
      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('global-high')),
        order: 10,
      );

      // Tagged with low order
      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('tagged-low')),
        tag: 'test',
        order: 1,
      );

      // Global with low order
      AopRegistry.instance.register(
        AopHooks(before: (ctx) => calls.add('global-low')),
        order: 2,
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'test',
        annotation: const Aop(tag: 'test'),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(context: context, invoke: () {});

      expect(calls, ['tagged-low', 'global-low', 'global-high']);
    });

    test(
      'hooks with same order keep registration order across global and tagged',
      () async {
        final calls = <String>[];

        AopRegistry.instance.register(
          AopHooks(before: (ctx) => calls.add('global-first')),
          order: 1,
        );

        AopRegistry.instance.register(
          AopHooks(before: (ctx) => calls.add('tagged-second')),
          tag: 'test',
          order: 1,
        );

        final context = AopContext(
          target: Object(),
          className: 'Service',
          methodName: 'test',
          annotation: const Aop(tag: 'test'),
          positionalArguments: const [],
          namedArguments: const {},
        );

        await runAsyncWithAop<void>(context: context, invoke: () {});

        expect(calls, ['global-first', 'tagged-second']);
      },
    );

    test('around hooks order affects chain execution', () async {
      final calls = <String>[];

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            calls.add('first-before');
            final result = await ctx.proceed();
            calls.add('first-after');
            return result;
          },
        ),
        order: 1,
      );

      AopRegistry.instance.register(
        AopHooks(
          around: (ctx) async {
            calls.add('second-before');
            final result = await ctx.proceed();
            calls.add('second-after');
            return result;
          },
        ),
        order: 2,
      );

      final context = AopContext(
        target: Object(),
        className: 'Service',
        methodName: 'test',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () => calls.add('original'),
      );

      expect(calls, [
        'first-before',
        'second-before',
        'original',
        'second-after',
        'first-after',
      ]);
    });
  });
}
