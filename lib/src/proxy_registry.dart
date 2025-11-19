import 'hooks.dart';

typedef _UntypedProxyFactory =
    Object Function(Object target, {AopHooks? hooks});

typedef AopProxyFactory<T> = T Function(T target, {AopHooks? hooks});

/// Stores generated proxy factories and exposes helper APIs to wrap objects.
class AopProxyRegistry {
  AopProxyRegistry._();

  static final AopProxyRegistry instance = AopProxyRegistry._();

  final Map<Type, _UntypedProxyFactory> _factories = {};

  /// Registers a proxy factory, usually invoked from generated code.
  void register<T>(AopProxyFactory<T> factory) {
    _factories[T] = (Object target, {AopHooks? hooks}) =>
        factory(target as T, hooks: hooks) as Object;
  }

  /// Wraps [target] with its generated proxy if available.
  T wrap<T>(T target, {AopHooks? hooks}) {
    final factory = _factories[T];
    if (factory == null) {
      return target;
    }
    return factory(target as Object, hooks: hooks) as T;
  }

  /// Removes every registered factory. Useful for tests.
  void clear() => _factories.clear();
}

/// Convenience helper mirroring Spring-style bean post processing.
T aopWrap<T>(T target, {AopHooks? hooks}) =>
    AopProxyRegistry.instance.wrap(target, hooks: hooks);
