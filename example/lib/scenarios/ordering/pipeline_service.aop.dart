// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'pipeline_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class PipelineServiceAopProxy implements PipelineService {
  PipelineServiceAopProxy(this._target, {AopHooks? hooks})
    : _localHooks = hooks;

  final PipelineService _target;
  final AopHooks? _localHooks;

  @override
  Future<String> process(String payload) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'pipeline',
    );
    final context = AopContext(
      target: _target,
      className: 'PipelineService',
      methodName: 'process',
      annotation: annotation,
      positionalArguments: <dynamic>[payload],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.process(payload),
    );
  }
  // Proxy for: Future<String> process(String payload)
}

bool _$flutterAopInitialized_lib_scenarios_ordering_pipeline_service_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_ordering_pipeline_service_dart() {
  if (_$flutterAopInitialized_lib_scenarios_ordering_pipeline_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_ordering_pipeline_service_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<PipelineService>(
    (PipelineService target, {AopHooks? hooks}) =>
        PipelineServiceAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_lib_scenarios_ordering_pipeline_service_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_ordering_pipeline_service_dart,
    );
void flutterAopBootstraplib_scenarios_ordering_pipeline_service_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_ordering_pipeline_service_dart;
}
