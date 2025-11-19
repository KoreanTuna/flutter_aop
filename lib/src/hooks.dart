import 'dart:async';

import 'context.dart';

typedef AopInterceptor = FutureOr<void> Function(AopContext context);

/// Collection of interceptors used by proxies.
class AopHooks {
  const AopHooks({this.before, this.after, this.onError});

  /// Called before the method executes.
  final AopInterceptor? before;

  /// Called after the method completes successfully.
  final AopInterceptor? after;

  /// Called when the method throws.
  final AopInterceptor? onError;

  AopHooks merge(AopHooks? other) {
    if (other == null) {
      return this;
    }
    return AopHooks(
      before: other.before ?? before,
      after: other.after ?? after,
      onError: other.onError ?? onError,
    );
  }
}
