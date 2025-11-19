import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AopRegistry.instance.clear());

  test('runSyncWithAop dispatches before and after hooks', () {
    final calls = <String>[];
    AopRegistry.instance.register(
      AopHooks(
        before: (context) => calls.add('before ${context.methodName}'),
        after: (context) => calls.add('after ${context.methodName}'),
      ),
    );

    final context = AopContext(
      target: Object(),
      className: 'Sample',
      methodName: 'calculate',
      annotation: const Aop(),
      positionalArguments: const <dynamic>[1, 2],
      namedArguments: const <String, dynamic>{},
    );

    final result = runSyncWithAop<int>(context: context, invoke: () => 42);

    expect(result, 42);
    expect(context.result, 42);
    expect(calls, ['before calculate', 'after calculate']);
  });

  test('runAsyncWithAop awaits hooks and exposes errors', () async {
    final captured = <String>[];
    AopRegistry.instance.register(
      AopHooks(
        onError: (context) async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        },
      ),
    );

    final context = AopContext(
      target: Object(),
      className: 'Repository',
      methodName: 'load',
      annotation: const Aop(onError: true, after: false),
      positionalArguments: const [],
      namedArguments: const {},
    );

    Future<void> failing() async {
      captured.add('invoke');
      throw StateError('network');
    }

    await expectLater(
      () => runAsyncWithAop<void>(context: context, invoke: failing),
      throwsStateError,
    );

    expect(captured, ['invoke']);
    expect(context.hasError, isTrue);
    expect(context.error, isStateError);
  });

  test('runSyncWithAop rejects async interceptors', () async {
    final context = AopContext(
      target: Object(),
      className: 'Target',
      methodName: 'syncCall',
      annotation: const Aop(),
      positionalArguments: const [],
      namedArguments: const {},
    );

    expect(
      () => runSyncWithAop<void>(
        context: context,
        invoke: () {},
        localHooks: AopHooks(before: (_) async {}),
      ),
      throwsStateError,
    );
  });
}
