// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'feature_flag_aspect.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

bool
_$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_aspect_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_short_circuit_feature_flag_aspect_dart() {
  if (_$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_aspect_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_short_circuit_feature_flag_aspect_dart =
      true;
  final hookRegistry = AopRegistry.instance;
  final aspect0 = const FeatureFlagAspect();
  hookRegistry.register(
    AopHooks(before: aspect0.routeOverride),
    tag: 'feature-flag',
    order: 0,
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool
_$flutterAopBootstrap_lib_scenarios_short_circuit_feature_flag_aspect_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_short_circuit_feature_flag_aspect_dart,
    );
void flutterAopBootstraplib_scenarios_short_circuit_feature_flag_aspect_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_short_circuit_feature_flag_aspect_dart;
}
