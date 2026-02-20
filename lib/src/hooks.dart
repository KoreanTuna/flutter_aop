import 'dart:async';

import 'context.dart';

/// Interceptor function type for before, after, and onError hooks.
///
/// These interceptors receive the [AopContext] and can inspect or modify it.
/// They do not return a value - use [AroundInterceptor] for that.
typedef AopInterceptor = FutureOr<void> Function(AopContext context);

/// Interceptor function type for around hooks.
///
/// Around interceptors wrap the entire method execution and must:
/// 1. Optionally call `context.proceed()` to execute the original method
/// 2. Return the result (either from proceed() or a custom value)
///
/// Example:
/// ```dart
/// AroundInterceptor timing = (ctx) async {
///   final sw = Stopwatch()..start();
///   final result = await ctx.proceed();
///   print('Took ${sw.elapsedMilliseconds}ms');
///   return result;
/// };
/// ```
typedef AroundInterceptor = FutureOr<dynamic> Function(AopContext context);

/// Collection of interceptors used by proxies.
///
/// This class holds the various hooks that can be attached to method calls.
/// Multiple [AopHooks] can be registered and will be executed in order.
///
/// Example:
/// ```dart
/// final hooks = AopHooks(
///   before: (ctx) => print('Before ${ctx.methodName}'),
///   after: (ctx) => print('After ${ctx.methodName}'),
///   onError: (ctx) => print('Error: ${ctx.error}'),
///   around: (ctx) async {
///     print('Around start');
///     final result = await ctx.proceed();
///     print('Around end');
///     return result;
///   },
/// );
/// ```
class AopHooks {
  /// Creates an [AopHooks] instance with the given interceptors.
  const AopHooks({
    this.before,
    this.after,
    this.onError,
    this.around,
  });

  /// Called before the method executes.
  ///
  /// Can inspect arguments, set up context, or skip execution via
  /// `context.skipWithResult()`.
  final AopInterceptor? before;

  /// Called after the method completes successfully.
  ///
  /// Can inspect or modify the result via `context.result`.
  final AopInterceptor? after;

  /// Called when the method throws.
  ///
  /// Can inspect the error via `context.error` and `context.stackTrace`.
  /// Set `context.error = null` to recover from the error.
  final AopInterceptor? onError;

  /// Wraps around the entire method execution.
  ///
  /// Must call `context.proceed()` to execute the original method,
  /// or return a value directly to skip execution.
  final AroundInterceptor? around;

  /// Returns true if any hook is defined.
  bool get hasAnyHook =>
      before != null || after != null || onError != null || around != null;

  /// Merges this hooks with another, with [other] taking precedence.
  ///
  /// Non-null values in [other] will override values in this instance.
  AopHooks merge(AopHooks? other) {
    if (other == null) {
      return this;
    }
    return AopHooks(
      before: other.before ?? before,
      after: other.after ?? after,
      onError: other.onError ?? onError,
      around: other.around ?? around,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (before != null) parts.add('before');
    if (after != null) parts.add('after');
    if (onError != null) parts.add('onError');
    if (around != null) parts.add('around');
    return 'AopHooks(${parts.join(', ')})';
  }
}
