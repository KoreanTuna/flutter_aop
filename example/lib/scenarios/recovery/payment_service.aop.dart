// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'payment_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class PaymentServiceAopProxy implements PaymentService {
  PaymentServiceAopProxy(this._target, {AopHooks? hooks}) : _localHooks = hooks;

  final PaymentService _target;
  final AopHooks? _localHooks;

  @override
  Future<String> charge(String userId) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'payment',
    );
    final context = AopContext(
      target: _target,
      className: 'PaymentService',
      methodName: 'charge',
      annotation: annotation,
      positionalArguments: <dynamic>[userId],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<String>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.charge(userId),
    );
  }
  // Proxy for: Future<String> charge(String userId)
}

bool _$flutterAopInitialized_lib_scenarios_recovery_payment_service_dart =
    false;
bool
_$flutterAopEnsureInitialized_lib_scenarios_recovery_payment_service_dart() {
  if (_$flutterAopInitialized_lib_scenarios_recovery_payment_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_scenarios_recovery_payment_service_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<PaymentService>(
    (PaymentService target, {AopHooks? hooks}) =>
        PaymentServiceAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_lib_scenarios_recovery_payment_service_dart =
    AopBootstrapper.instance.register(
      _$flutterAopEnsureInitialized_lib_scenarios_recovery_payment_service_dart,
    );
void flutterAopBootstraplib_scenarios_recovery_payment_service_dart() {
  // ignore: unused_local_variable
  final bool _ =
      _$flutterAopBootstrap_lib_scenarios_recovery_payment_service_dart;
}
