// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'payment_recovery_aspect.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

bool
_$flutterAopInitialized_lib_scenarios_recovery_payment_recovery_aspect_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_recovery_payment_recovery_aspect_dart() {
  if (_$flutterAopInitialized_lib_scenarios_recovery_payment_recovery_aspect_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_recovery_payment_recovery_aspect_dart =
      true;
  final hookRegistry = AopRegistry.instance;
  final aspect0 = const PaymentRecoveryAspect();
  hookRegistry.register(
    AopHooks(onError: aspect0.recover),
    tag: 'payment',
    order: 0,
  );
  hookRegistry.register(
    AopHooks(after: aspect0.after),
    tag: 'payment',
    order: 0,
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool
_$flutterAopBootstrap_lib_scenarios_recovery_payment_recovery_aspect_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_recovery_payment_recovery_aspect_dart,
    );
void flutterAopBootstraplib_scenarios_recovery_payment_recovery_aspect_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_recovery_payment_recovery_aspect_dart;
}
