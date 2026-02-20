import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createObservationHooks emits before and after events', () async {
    final events = <AopObservationEvent>[];
    final context = AopContext(
      target: Object(),
      className: 'UserService',
      methodName: 'load',
      annotation: const Aop(tag: 'obs'),
      positionalArguments: const <dynamic>[1],
      namedArguments: const <String, dynamic>{'include': true},
    );

    final result = await runAsyncWithAop<String>(
      context: context,
      invoke: () async {
        await Future<void>.delayed(const Duration(milliseconds: 2));
        return 'ok';
      },
      localHooks: createObservationHooks(sink: events.add, includeResult: true),
    );

    expect(result, 'ok');
    expect(events.map((event) => event.phase), [
      AopObservationPhase.before,
      AopObservationPhase.after,
    ]);
    expect(events.first.result, isNull);
    expect(events.last.result, 'ok');
    expect(events.last.elapsed, greaterThan(Duration.zero));
    expect(events.first.invocationId, context.invocationId);
    expect(events.last.invocationId, context.invocationId);
  });

  test(
    'createObservationHooks emits error event with optional stack trace',
    () async {
      final events = <AopObservationEvent>[];
      final context = AopContext(
        target: Object(),
        className: 'UserService',
        methodName: 'save',
        annotation: const Aop(tag: 'obs'),
        positionalArguments: const <dynamic>[7],
        namedArguments: const <String, dynamic>{},
      );

      await expectLater(
        () => runAsyncWithAop<void>(
          context: context,
          invoke: () => throw StateError('boom'),
          localHooks: createObservationHooks(
            sink: events.add,
            includeStackTrace: true,
          ),
        ),
        throwsStateError,
      );

      expect(events.map((event) => event.phase), [
        AopObservationPhase.before,
        AopObservationPhase.error,
      ]);
      expect(events.last.error, isA<StateError>());
      expect(events.last.stackTrace, isNotNull);
    },
  );

  test('createObservationHooks controls argument payload inclusion', () async {
    final events = <AopObservationEvent>[];
    final context = AopContext(
      target: Object(),
      className: 'UserService',
      methodName: 'fetch',
      annotation: const Aop(tag: 'obs'),
      positionalArguments: const <dynamic>[1, 2],
      namedArguments: const <String, dynamic>{'locale': 'ko'},
    );

    await runAsyncWithAop<void>(
      context: context,
      invoke: () {},
      localHooks: createObservationHooks(
        sink: events.add,
        includeArguments: true,
      ),
    );

    expect(events.first.positionalArguments, [1, 2]);
    expect(events.first.namedArguments, {'locale': 'ko'});
  });

  test(
    'createObservationHooks marks slow calls when threshold is exceeded',
    () async {
      final events = <AopObservationEvent>[];
      final context = AopContext(
        target: Object(),
        className: 'UserService',
        methodName: 'slowCall',
        annotation: const Aop(tag: 'obs'),
        positionalArguments: const <dynamic>[],
        namedArguments: const <String, dynamic>{},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        },
        localHooks: createObservationHooks(
          sink: events.add,
          slowCallThreshold: const Duration(milliseconds: 1),
        ),
      );

      expect(events.last.phase, AopObservationPhase.after);
      expect(events.last.isSlow, isTrue);
    },
  );
}
