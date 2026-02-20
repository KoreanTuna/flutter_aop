// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'repository_pointcut_aspect.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

bool
_$flutterAopInitialized_lib_scenarios_pointcut_repository_pointcut_aspect_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_pointcut_repository_pointcut_aspect_dart() {
  if (_$flutterAopInitialized_lib_scenarios_pointcut_repository_pointcut_aspect_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_pointcut_repository_pointcut_aspect_dart =
      true;
  final hookRegistry = AopRegistry.instance;
  final aspect0 = const RepositoryPointcutAspect();
  hookRegistry.registerWithPointcut(
    AopHooks(before: aspect0.beforeFind),
    pointcut: const Pointcut(
      classPattern: '*Repository',
      methodPattern: 'find*',
    ),
    order: 0,
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool
_$flutterAopBootstrap_lib_scenarios_pointcut_repository_pointcut_aspect_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_pointcut_repository_pointcut_aspect_dart,
    );
void
flutterAopBootstraplib_scenarios_pointcut_repository_pointcut_aspect_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_pointcut_repository_pointcut_aspect_dart;
}
