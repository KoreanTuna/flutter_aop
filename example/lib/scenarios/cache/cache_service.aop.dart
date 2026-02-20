// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'cache_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class CatalogServiceAopProxy implements CatalogService {
  CatalogServiceAopProxy(this._target, {AopHooks? hooks}) : _localHooks = hooks;

  final CatalogService _target;
  final AopHooks? _localHooks;

  @override
  int get loadCount => _target.loadCount;

  @override
  set loadCount(int value) => _target.loadCount = value;

  @override
  Future<List<String>> loadProducts(String category) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'cache',
      description: 'Load product list from remote source',
    );
    final context = AopContext(
      target: _target,
      className: 'CatalogService',
      methodName: 'loadProducts',
      annotation: annotation,
      positionalArguments: <dynamic>[category],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<List<String>>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.loadProducts(category),
    );
  }
  // Proxy for: Future<List<String>> loadProducts(String category)
}

bool _$flutterAopInitialized_lib_scenarios_cache_cache_service_dart = false;
bool _$flutterAopEnsureInitialized_lib_scenarios_cache_cache_service_dart() {
  if (_$flutterAopInitialized_lib_scenarios_cache_cache_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_cache_cache_service_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<CatalogService>(
    (CatalogService target, {AopHooks? hooks}) =>
        CatalogServiceAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_lib_scenarios_cache_cache_service_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_cache_cache_service_dart,
    );
void flutterAopBootstraplib_scenarios_cache_cache_service_dart() {
  // ignore: unused_local_variable
  final bool _ = _$flutterAopBootstrap_lib_scenarios_cache_cache_service_dart;
}
