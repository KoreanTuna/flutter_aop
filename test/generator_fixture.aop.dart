// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'generator_fixture.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class GeneratorPointcutServiceAopProxy implements GeneratorPointcutService {
  GeneratorPointcutServiceAopProxy(this._target, {AopHooks? hooks})
    : _localHooks = hooks;

  final GeneratorPointcutService _target;
  final AopHooks? _localHooks;

  @override
  String findById(String id) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'audit',
    );
    final context = AopContext(
      target: _target,
      className: 'GeneratorPointcutService',
      methodName: 'findById',
      annotation: annotation,
      positionalArguments: <dynamic>[id],
      namedArguments: const <String, dynamic>{},
    );
    return runSyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.findById(id),
    );
  }
  // Proxy for: String findById(String id)

  @override
  String findOther(String id) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'other',
    );
    final context = AopContext(
      target: _target,
      className: 'GeneratorPointcutService',
      methodName: 'findOther',
      annotation: annotation,
      positionalArguments: <dynamic>[id],
      namedArguments: const <String, dynamic>{},
    );
    return runSyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.findOther(id),
    );
  }
  // Proxy for: String findOther(String id)
}

class GeneratorGenericServiceAopProxy implements GeneratorGenericService {
  GeneratorGenericServiceAopProxy(this._target, {AopHooks? hooks})
    : _localHooks = hooks;

  final GeneratorGenericService _target;
  final AopHooks? _localHooks;

  @override
  T echo<T extends Object>(T value) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'generic',
    );
    final context = AopContext(
      target: _target,
      className: 'GeneratorGenericService',
      methodName: 'echo',
      annotation: annotation,
      positionalArguments: <dynamic>[value],
      namedArguments: const <String, dynamic>{},
    );
    return runSyncWithAop<T>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.echo<T>(value),
    );
  }
  // Proxy for: T echo(T value)
}

bool _$flutterAopInitialized_test_generator_fixture_dart = false;
bool _$flutterAopEnsureInitialized_test_generator_fixture_dart() {
  if (_$flutterAopInitialized_test_generator_fixture_dart) {
    return true;
  }
  _$flutterAopInitialized_test_generator_fixture_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<GeneratorPointcutService>(
    (GeneratorPointcutService target, {AopHooks? hooks}) =>
        GeneratorPointcutServiceAopProxy(target, hooks: hooks),
  );
  proxyRegistry.register<GeneratorGenericService>(
    (GeneratorGenericService target, {AopHooks? hooks}) =>
        GeneratorGenericServiceAopProxy(target, hooks: hooks),
  );
  final hookRegistry = AopRegistry.instance;
  final aspect0 = const GeneratorPointcutAspect();
  hookRegistry.registerWithPointcut(
    AopHooks(before: aspect0.before),
    pointcut: const Pointcut(
      classPattern: '*Service',
      methodPattern: 'find*',
      tag: 'audit',
    ),
    order: 0,
  );
  final aspect1 = const GeneratorGenericAspect();
  hookRegistry.register(
    AopHooks(before: aspect1.before),
    tag: 'generic',
    order: 0,
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_test_generator_fixture_dart = AopBootstrapper
    .instance
    .register(_$flutterAopEnsureInitialized_test_generator_fixture_dart);
void flutterAopBootstraptest_generator_fixture_dart() {
  // ignore: unused_local_variable
  final bool _ = _$flutterAopBootstrap_test_generator_fixture_dart;
}
