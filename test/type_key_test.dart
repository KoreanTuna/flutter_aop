import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

// Test classes for generic type support
class Repository<T> {}

class User {}

class Product {}

void main() {
  group('TypeKey', () {
    test('TypeKey.of creates key for simple type', () {
      final key1 = TypeKey.of<String>();
      final key2 = TypeKey.of<String>();
      final key3 = TypeKey.of<int>();

      expect(key1, equals(key2));
      expect(key1, isNot(equals(key3)));
    });

    test('TypeKey with same base type and args are equal', () {
      final key1 = TypeKey.withArgs(Repository, [User]);
      final key2 = TypeKey.withArgs(Repository, [User]);

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('TypeKey with different type args are not equal', () {
      final key1 = TypeKey.withArgs(Repository, [User]);
      final key2 = TypeKey.withArgs(Repository, [Product]);

      expect(key1, isNot(equals(key2)));
    });

    test('TypeKey isGeneric returns correct value', () {
      final simple = TypeKey.of<String>();
      final generic = TypeKey.withArgs(Repository, [User]);

      expect(simple.isGeneric, isFalse);
      expect(generic.isGeneric, isTrue);
    });

    test('TypeKey toString includes type arguments', () {
      final key = TypeKey.withArgs(Repository, [User]);

      expect(key.toString(), contains('Repository'));
      expect(key.toString(), contains('User'));
    });
  });

  group('AopProxyRegistry with TypeKey', () {
    setUp(() => AopProxyRegistry.instance.clear());

    test('registerGeneric and wrapGeneric work correctly', () {
      var proxyCalled = false;

      AopProxyRegistry.instance.registerGeneric<Repository<User>>(
        (target, {hooks}) {
          proxyCalled = true;
          return target;
        },
        typeKey: TypeKey.withArgs(Repository, [User]),
      );

      final repo = Repository<User>();
      final wrapped = aopWrapGeneric(
        repo,
        TypeKey.withArgs(Repository, [User]),
      );

      expect(proxyCalled, isTrue);
      expect(wrapped, same(repo));
    });

    test('different TypeKeys get different factories', () {
      var userFactoryCalled = false;
      var productFactoryCalled = false;

      AopProxyRegistry.instance.registerGeneric<Repository<User>>(
        (target, {hooks}) {
          userFactoryCalled = true;
          return target;
        },
        typeKey: TypeKey.withArgs(Repository, [User]),
      );

      AopProxyRegistry.instance.registerGeneric<Repository<Product>>(
        (target, {hooks}) {
          productFactoryCalled = true;
          return target;
        },
        typeKey: TypeKey.withArgs(Repository, [Product]),
      );

      aopWrapGeneric(
        Repository<User>(),
        TypeKey.withArgs(Repository, [User]),
      );

      expect(userFactoryCalled, isTrue);
      expect(productFactoryCalled, isFalse);

      userFactoryCalled = false;

      aopWrapGeneric(
        Repository<Product>(),
        TypeKey.withArgs(Repository, [Product]),
      );

      expect(userFactoryCalled, isFalse);
      expect(productFactoryCalled, isTrue);
    });

    test('hasGenericFactory returns correct value', () {
      final key = TypeKey.withArgs(Repository, [User]);

      expect(AopProxyRegistry.instance.hasGenericFactory(key), isFalse);

      AopProxyRegistry.instance.registerGeneric<Repository<User>>(
        (target, {hooks}) => target,
        typeKey: key,
      );

      expect(AopProxyRegistry.instance.hasGenericFactory(key), isTrue);
    });

    test('wrapGeneric returns original if no factory registered', () {
      final repo = Repository<User>();
      final wrapped = aopWrapGeneric(
        repo,
        TypeKey.withArgs(Repository, [User]),
      );

      expect(wrapped, same(repo));
    });
  });
}
