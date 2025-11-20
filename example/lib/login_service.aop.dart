// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// ignore_for_file: type=lint
// dart format width=80

part of 'login_service.dart';

// **************************************************************************
// AopGenerator
// **************************************************************************

class LoginServiceAopProxy implements LoginService {
  LoginServiceAopProxy(this._target, {AopHooks? hooks}) : _localHooks = hooks;

  final LoginService _target;
  final AopHooks? _localHooks;

  @override
  Future<void> login(String id, String password) {
    const annotation = Aop(
      before: true,
      after: true,
      onError: true,
      tag: 'auth',
      description: 'Authenticate the user against a remote server',
    );
    final context = AopContext(
      target: _target,
      className: 'LoginService',
      methodName: 'login',
      annotation: annotation,
      positionalArguments: <dynamic>[id, password],
      namedArguments: const <String, dynamic>{},
    );
    return runAsyncWithAop<void>(
      context: context,
      localHooks: _localHooks,
      invoke: () => _target.login(id, password),
    );
  }
  // Proxy for: Future<void> login(String id, String password)

  @override
  Future<void> noneAopLogin(String id, String password) =>
      _target.noneAopLogin(id, password);
}

bool _$flutterAopInitialized_lib_login_service_dart = false;
bool _$flutterAopEnsureInitialized_lib_login_service_dart() {
  if (_$flutterAopInitialized_lib_login_service_dart) {
    return true;
  }
  _$flutterAopInitialized_lib_login_service_dart = true;
  final proxyRegistry = AopProxyRegistry.instance;
  proxyRegistry.register<LoginService>(
    (LoginService target, {AopHooks? hooks}) =>
        LoginServiceAopProxy(target, hooks: hooks),
  );
  return true;
}

@pragma('vm:entry-point', 'flutter_aop_bootstrap')
final bool _$flutterAopBootstrap_lib_login_service_dart = AopBootstrapper
    .instance
    .register(_$flutterAopEnsureInitialized_lib_login_service_dart);
void flutterAopBootstraplib_login_service_dart() {
  // ignore: unused_local_variable
  final bool _ = _$flutterAopBootstrap_lib_login_service_dart;
}
