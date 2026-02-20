// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'repository_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class UserRepositoryAopProxy implements UserRepository {
  UserRepositoryAopProxy(this._target, {AopHooks? hooks}) : _localHooks = hooks;

  final UserRepository _target;
  final AopHooks? _localHooks;

  @override
  Future<String> findUserById(int id) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'repo',
    );
    final context = AopContext(
      target: _target,
      className: 'UserRepository',
      methodName: 'findUserById',
      annotation: annotation,
      positionalArguments: <dynamic>[id],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.findUserById(id),
    );
  }
  // Proxy for: Future<String> findUserById(int id)

  @override
  Future<void> saveUser(String name) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'repo',
    );
    final context = AopContext(
      target: _target,
      className: 'UserRepository',
      methodName: 'saveUser',
      annotation: annotation,
      positionalArguments: <dynamic>[name],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<void>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.saveUser(name),
    );
  }
  // Proxy for: Future<void> saveUser(String name)
}

class OrderRepositoryAopProxy implements OrderRepository {
  OrderRepositoryAopProxy(this._target, {AopHooks? hooks})
    : _localHooks = hooks;

  final OrderRepository _target;
  final AopHooks? _localHooks;

  @override
  Future<String> findOrderById(int id) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'repo',
    );
    final context = AopContext(
      target: _target,
      className: 'OrderRepository',
      methodName: 'findOrderById',
      annotation: annotation,
      positionalArguments: <dynamic>[id],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.findOrderById(id),
    );
  }
  // Proxy for: Future<String> findOrderById(int id)
}

bool _$flutterAopInitialized_lib_scenarios_pointcut_repository_service_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_pointcut_repository_service_dart() {
  if (_$flutterAopInitialized_lib_scenarios_pointcut_repository_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_pointcut_repository_service_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<UserRepository>(
    (UserRepository target, {AopHooks? hooks}) =>
        UserRepositoryAopProxy(target, hooks: hooks),
  );
  proxyRegistry.register<OrderRepository>(
    (OrderRepository target, {AopHooks? hooks}) =>
        OrderRepositoryAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool
_$flutterAopBootstrap_lib_scenarios_pointcut_repository_service_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_pointcut_repository_service_dart,
    );
void flutterAopBootstraplib_scenarios_pointcut_repository_service_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_pointcut_repository_service_dart;
}
