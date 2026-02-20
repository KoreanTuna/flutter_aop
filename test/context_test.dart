import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AopContext', () {
    late AopContext context;

    setUp(() {
      context = AopContext(
        target: Object(),
        className: 'TestService',
        methodName: 'testMethod',
        annotation: const Aop(tag: 'test'),
        positionalArguments: <dynamic>[1, 'hello', true],
        namedArguments: <String, dynamic>{'name': 'John', 'age': 30},
      );
    });

    test('initial state is beforeInvocation', () {
      expect(context.state, AopExecutionState.beforeInvocation);
    });

    test('invocationId is unique per context', () {
      final next = AopContext(
        target: Object(),
        className: 'TestService',
        methodName: 'nextMethod',
        annotation: const Aop(tag: 'test'),
        positionalArguments: const <dynamic>[],
        namedArguments: const <String, dynamic>{},
      );

      expect(next.invocationId, greaterThan(context.invocationId));
    });

    test('startedAt is initialized at construction time', () {
      expect(
        DateTime.now().difference(context.startedAt).inSeconds,
        lessThan(5),
      );
    });

    test('getArg returns positional argument with correct type', () {
      expect(context.getArg<int>(0), 1);
      expect(context.getArg<String>(1), 'hello');
      expect(context.getArg<bool>(2), true);
    });

    test('getNamedArg returns named argument with correct type', () {
      expect(context.getNamedArg<String>('name'), 'John');
      expect(context.getNamedArg<int>('age'), 30);
    });

    test('getNamedArgOr returns default value if key not found', () {
      expect(context.getNamedArgOr<String>('missing', 'default'), 'default');
      expect(context.getNamedArgOr<String>('name', 'default'), 'John');
    });

    test('skipWithResult sets skip flag, result, and state', () {
      context.skipWithResult('cached value');

      expect(context.skipInvocation, isTrue);
      expect(context.result, 'cached value');
      expect(context.state, AopExecutionState.skipped);
    });

    test('attribute helpers store and retrieve values', () {
      context.setAttribute('timer', 123);

      expect(context.hasAttribute('timer'), isTrue);
      expect(context.getAttribute<int>('timer'), 123);
      expect(context.removeAttribute('timer'), 123);
      expect(context.hasAttribute('timer'), isFalse);
      expect(context.getAttribute<int>('timer'), isNull);
    });

    test('markSuccess updates state', () {
      context.markSuccess();
      expect(context.state, AopExecutionState.afterSuccess);
    });

    test('markError updates state', () {
      context.markError();
      expect(context.state, AopExecutionState.afterError);
    });

    test('joinPointDescription returns correct format', () {
      expect(context.joinPointDescription, 'TestService.testMethod');
    });

    test('getResult returns typed result', () {
      context.result = 42;
      expect(context.getResult<int>(), 42);
    });

    test('getError returns typed error or null', () {
      context.error = StateError('test');
      expect(context.getError<StateError>(), isA<StateError>());
      expect(context.getError<ArgumentError>(), isNull);
    });

    test('proceed throws StateError when not in around context', () {
      expect(() => context.proceed(), throwsStateError);
    });

    test('canProceed returns false initially', () {
      expect(context.canProceed, isFalse);
    });

    test('setProceed enables proceed()', () {
      context.setProceed(() => 'result');

      expect(context.canProceed, isTrue);
      expect(context.proceed(), 'result');
    });

    test('clearProceed disables proceed()', () {
      context.setProceed(() => 'result');
      context.clearProceed();

      expect(context.canProceed, isFalse);
      expect(() => context.proceed(), throwsStateError);
    });

    test('toString includes relevant information', () {
      context.result = 'test result';
      final str = context.toString();

      expect(str, contains('TestService.testMethod'));
      expect(str, contains('beforeInvocation'));
      expect(str, contains('test result'));
    });
  });

  group('AopExecutionState', () {
    test('all states are distinct', () {
      final states = AopExecutionState.values;
      expect(states.length, 5);
      expect(states.toSet().length, 5);
    });
  });
}
