import 'hooks.dart';
import 'type_key.dart';

typedef _UntypedProxyFactory =
    Object Function(Object target, {AopHooks? hooks});

/// Factory function type for creating proxy instances.
typedef AopProxyFactory<T> = T Function(T target, {AopHooks? hooks});

/// Stores generated proxy factories and exposes helper APIs to wrap objects.
///
/// The registry supports two types of registration:
/// 1. Simple type-based registration for non-generic classes
/// 2. TypeKey-based registration for generic classes
///
/// Example:
/// ```dart
/// // Simple registration (non-generic)
/// AopProxyRegistry.instance.register<UserService>(
///   (target, {hooks}) => UserServiceAopProxy(target, hooks: hooks),
/// );
///
/// // Generic registration
/// AopProxyRegistry.instance.registerGeneric<Repository<User>>(
///   (target, {hooks}) => RepositoryAopProxy(target, hooks: hooks),
///   typeKey: TypeKey.withArgs(Repository, [User]),
/// );
///
/// // Usage
/// final service = aopWrap(UserService());
/// final repo = aopWrapGeneric(UserRepository(), TypeKey.withArgs(Repository, [User]));
/// ```
class AopProxyRegistry {
  AopProxyRegistry._();

  /// Singleton access to the registry.
  static final AopProxyRegistry instance = AopProxyRegistry._();

  /// Simple type-based factories (for non-generic types).
  final Map<Type, _UntypedProxyFactory> _factories = {};

  /// TypeKey-based factories (for generic types).
  final Map<TypeKey, _UntypedProxyFactory> _genericFactories = {};

  /// Registers a proxy factory for a non-generic type.
  ///
  /// Usually invoked from generated code.
  void register<T>(AopProxyFactory<T> factory) {
    _factories[T] = (Object target, {AopHooks? hooks}) =>
        factory(target as T, hooks: hooks) as Object;
  }

  /// Registers a proxy factory for a generic type with specific type arguments.
  ///
  /// Use this when you need to register different proxy factories for different
  /// generic instantiations (e.g., `Repository<User>` vs
  /// `Repository<Product>`).
  ///
  /// Example:
  /// ```dart
  /// AopProxyRegistry.instance.registerGeneric<Repository<User>>(
  ///   (target, {hooks}) => RepositoryAopProxy<User>(target, hooks: hooks),
  ///   typeKey: TypeKey.withArgs(Repository, [User]),
  /// );
  /// ```
  void registerGeneric<T>(
    AopProxyFactory<T> factory, {
    required TypeKey typeKey,
  }) {
    _genericFactories[typeKey] = (Object target, {AopHooks? hooks}) =>
        factory(target as T, hooks: hooks) as Object;
  }

  /// Wraps [target] with its generated proxy if available.
  ///
  /// First checks simple type-based factories, then falls back to TypeKey-based
  /// factories if a [typeKey] is provided.
  T wrap<T>(T target, {AopHooks? hooks, TypeKey? typeKey}) {
    _UntypedProxyFactory? factory;

    // First try TypeKey-based factory if provided
    if (typeKey != null) {
      factory = _genericFactories[typeKey];
    }

    // Fall back to simple type lookup
    factory ??= _factories[T];

    if (factory == null) {
      return target;
    }
    return factory(target as Object, hooks: hooks) as T;
  }

  /// Wraps [target] with a generic proxy using an explicit [TypeKey].
  ///
  /// Use this when wrapping instances of generic classes.
  ///
  /// Example:
  /// ```dart
  /// final userRepo = aopWrapGeneric(
  ///   UserRepository(),
  ///   TypeKey.withArgs(Repository, [User]),
  /// );
  /// ```
  T wrapGeneric<T>(T target, TypeKey typeKey, {AopHooks? hooks}) {
    final factory = _genericFactories[typeKey] ?? _factories[T];
    if (factory == null) {
      return target;
    }
    return factory(target as Object, hooks: hooks) as T;
  }

  /// Checks if a factory is registered for the given type.
  bool hasFactory<T>() => _factories.containsKey(T);

  /// Checks if a factory is registered for the given TypeKey.
  bool hasGenericFactory(TypeKey typeKey) =>
      _genericFactories.containsKey(typeKey);

  /// Returns the number of registered simple type factories.
  int get factoryCount => _factories.length;

  /// Returns the number of registered generic type factories.
  int get genericFactoryCount => _genericFactories.length;

  /// Removes every registered factory. Useful for tests.
  void clear() {
    _factories.clear();
    _genericFactories.clear();
  }
}

/// Convenience helper mirroring Spring-style bean post processing.
///
/// Wraps [target] with its generated proxy if available.
T aopWrap<T>(T target, {AopHooks? hooks}) =>
    AopProxyRegistry.instance.wrap(target, hooks: hooks);

/// Convenience helper for wrapping generic types.
///
/// Use this when you need to wrap instances of generic classes with specific
/// type arguments.
///
/// Example:
/// ```dart
/// final userRepo = aopWrapGeneric(
///   UserRepository(),
///   TypeKey.withArgs(Repository, [User]),
/// );
/// ```
T aopWrapGeneric<T>(T target, TypeKey typeKey, {AopHooks? hooks}) =>
    AopProxyRegistry.instance.wrapGeneric(target, typeKey, hooks: hooks);
