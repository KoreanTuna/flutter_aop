// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'logging_aspect.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

bool _$flutterAopInitialized_lib_aspect_logging_aspect_dart = false;
bool _$flutterAopEnsureInitialized_lib_aspect_logging_aspect_dart() {
  if (_$flutterAopInitialized_lib_aspect_logging_aspect_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_aspect_logging_aspect_dart = true;
  final hookRegistry = AopRegistry.instance;
  final aspect0 = const LoggingAspect();
  hookRegistry.register(AopHooks(before: aspect0.logBefore), tag: 'auth');
  hookRegistry.register(AopHooks(after: aspect0.logAfter), tag: 'auth');
  hookRegistry.register(AopHooks(onError: aspect0.logError), tag: 'auth');
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_lib_aspect_logging_aspect_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_aspect_logging_aspect_dart,
    );
void flutterAopBootstraplib_aspect_logging_aspect_dart() {
  // ignore: unused_local_variable
  final bool _ = _$flutterAopBootstrap_lib_aspect_logging_aspect_dart;
}
