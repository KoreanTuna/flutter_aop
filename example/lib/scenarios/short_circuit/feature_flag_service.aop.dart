// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'feature_flag_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class FeatureFlagServiceAopProxy implements FeatureFlagService {
  FeatureFlagServiceAopProxy(this._target, {AopHooks? hooks})
    : _localHooks = hooks;

  final FeatureFlagService _target;
  final AopHooks? _localHooks;

  @override
  String checkoutRoute() {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'feature-flag',
    );
    final context = AopContext(
      target: _target,
      className: 'FeatureFlagService',
      methodName: 'checkoutRoute',
      annotation: annotation,
      positionalArguments: const <dynamic>[],
      namedArguments: const <String, dynamic>{},
    );
    return runSyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.checkoutRoute(),
    );
  }
  // Proxy for: String checkoutRoute()
}

bool
_$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_service_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_short_circuit_feature_flag_service_dart() {
  if (_$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_service_dart =
      true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<FeatureFlagService>(
    (FeatureFlagService target, {AopHooks? hooks}) =>
        FeatureFlagServiceAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool
_$flutterAopBootstrap_lib_scenarios_short_circuit_feature_flag_service_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_short_circuit_feature_flag_service_dart,
    );
void
flutterAopBootstraplib_scenarios_short_circuit_feature_flag_service_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_short_circuit_feature_flag_service_dart;
}
