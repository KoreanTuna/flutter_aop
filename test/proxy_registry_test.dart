import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

class _TargetService {
  int calls = 0;

  void call() {
    calls += 1;
  }
}

class _TargetServiceProxy extends _TargetService {
  _TargetServiceProxy(this._delegate);

  final _TargetService _delegate;

  @override
  void call() {
    _delegate.call();
  }
}

void main() {
  setUp(() => AopProxyRegistry.instance.clear());

  test('wrap returns original when no proxy is registered', () {
    final service = _TargetService();

    final wrapped = AopProxyRegistry.instance.wrap(service);

    expect(identical(service, wrapped), isTrue);
  });

  test('wrap delegates to registered proxy factories', () {
    final service = _TargetService();
    AopProxyRegistry.instance.register<_TargetService>(
      (target, {hooks}) => _TargetServiceProxy(target),
    );

    final wrapped = aopWrap(service);

    expect(wrapped, isA<_TargetServiceProxy>());
    wrapped.call();
    expect(service.calls, 1);
  });
}
