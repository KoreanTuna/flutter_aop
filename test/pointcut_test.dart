import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pointcut matching', () {
    test('matches class pattern with * wildcard at end', () {
      const pointcut = Pointcut(classPattern: '*Service');

      expect(
        pointcut.matches(
          className: 'UserService',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'LoginService',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'UserRepository',
          methodName: 'test',
        ),
        isFalse,
      );
    });

    test('matches class pattern with * wildcard at start', () {
      const pointcut = Pointcut(classPattern: 'User*');

      expect(
        pointcut.matches(
          className: 'UserService',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'UserRepository',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'LoginService',
          methodName: 'test',
        ),
        isFalse,
      );
    });

    test('matches method pattern with * wildcard', () {
      const pointcut = Pointcut(methodPattern: 'get*');

      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'getUser',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'getUserById',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'fetchUser',
        ),
        isFalse,
      );
    });

    test('matches ? wildcard for single character', () {
      const pointcut = Pointcut(methodPattern: 'get?ser');

      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'getUser',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'getAser',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'getAllUser',
        ),
        isFalse,
      );
    });

    test('combines class and method patterns', () {
      const pointcut = Pointcut(
        classPattern: '*Repository',
        methodPattern: 'find*',
      );

      expect(
        pointcut.matches(
          className: 'UserRepository',
          methodName: 'findById',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'UserRepository',
          methodName: 'save',
        ),
        isFalse,
      );
      expect(
        pointcut.matches(
          className: 'UserService',
          methodName: 'findById',
        ),
        isFalse,
      );
    });

    test('matches tag in pointcut', () {
      const pointcut = Pointcut(tag: 'auth');

      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'login',
          annotationTag: 'auth',
        ),
        isTrue,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'login',
          annotationTag: 'other',
        ),
        isFalse,
      );
      expect(
        pointcut.matches(
          className: 'Service',
          methodName: 'login',
          annotationTag: null,
        ),
        isFalse,
      );
    });

    test('Pointcuts convenience constants work', () {
      expect(
        Pointcuts.allServices.matches(
          className: 'UserService',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        Pointcuts.allRepositories.matches(
          className: 'UserRepository',
          methodName: 'test',
        ),
        isTrue,
      );
      expect(
        Pointcuts.allGetters.matches(
          className: 'Service',
          methodName: 'getUser',
        ),
        isTrue,
      );
    });
  });

  group('Pointcut in registry', () {
    setUp(() => AopRegistry.instance.clear());

    test('pointcut-based hooks are triggered', () async {
      final calls = <String>[];

      AopRegistry.instance.registerWithPointcut(
        AopHooks(
          before: (ctx) => calls.add('pointcut-before'),
        ),
        pointcut: const Pointcut(classPattern: '*Service'),
      );

      final context = AopContext(
        target: Object(),
        className: 'UserService',
        methodName: 'test',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () => calls.add('original'),
      );

      expect(calls, ['pointcut-before', 'original']);
    });

    test('pointcut-based hooks are not triggered for non-matching', () async {
      final calls = <String>[];

      AopRegistry.instance.registerWithPointcut(
        AopHooks(
          before: (ctx) => calls.add('pointcut-before'),
        ),
        pointcut: const Pointcut(classPattern: '*Service'),
      );

      final context = AopContext(
        target: Object(),
        className: 'UserRepository',
        methodName: 'test',
        annotation: const Aop(),
        positionalArguments: const [],
        namedArguments: const {},
      );

      await runAsyncWithAop<void>(
        context: context,
        invoke: () => calls.add('original'),
      );

      expect(calls, ['original']);
    });
  });
}
