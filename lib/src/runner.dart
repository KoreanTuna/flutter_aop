import 'dart:async';

import 'context.dart';
import 'hooks.dart';
import 'registry.dart';

/// Collects all applicable hooks for the given context.
List<AopHooks> _collectHooks(AopContext context, AopHooks? localHooks) {
  final hooks = <AopHooks>[];
  if (localHooks != null) {
    hooks.add(localHooks);
  }
  // Use resolveForContext to include pointcut-based hooks
  hooks.addAll(AopRegistry.instance.resolveForContext(context));
  return hooks;
}

/// Runs async hooks sequentially.
Future<void> _runAsyncHooks(
  Iterable<AopHooks> hooks,
  AopInterceptor? Function(AopHooks hook) pick,
  AopContext context,
) async {
  for (final hook in hooks) {
    final interceptor = pick(hook);
    if (interceptor == null) continue;
    await Future.sync(() => interceptor(context));
  }
}

/// Runs sync hooks, throwing if any returns a Future.
void _runSyncHooks(
  Iterable<AopHooks> hooks,
  AopInterceptor? Function(AopHooks hook) pick,
  AopContext context,
) {
  for (final hook in hooks) {
    final interceptor = pick(hook);
    if (interceptor == null) continue;
    final result = interceptor(context);
    if (result is Future) {
      throw StateError(
        'Async hooks are not supported for synchronous methods '
        '(${context.className}.${context.methodName}). '
        'Mark the method as async or return a Future.',
      );
    }
  }
}

/// Extracts the result from context with proper typing.
R _result<R>(AopContext context) => context.result as R;

/// Throws the error stored in context if present.
void _throwIfError(AopContext context) {
  if (!context.hasError) return;
  Error.throwWithStackTrace(
    context.error!,
    context.stackTrace ?? StackTrace.current,
  );
}

/// Collects around interceptors from hooks.
List<AroundInterceptor> _collectAroundInterceptors(List<AopHooks> hooks) {
  return hooks
      .map((h) => h.around)
      .whereType<AroundInterceptor>()
      .toList();
}

/// Executes an async method with AOP hooks.
///
/// Execution flow:
/// 1. Around chain (if any) wraps the entire execution
/// 2. Before hooks run
/// 3. Original method invokes (unless skipInvocation is set)
/// 4. After hooks run (on success) or OnError hooks run (on failure)
/// 5. Result returns through the around chain
///
/// Example:
/// ```dart
/// final result = await runAsyncWithAop<String>(
///   context: context,
///   invoke: () => originalMethod(),
///   localHooks: customHooks,
/// );
/// ```
Future<R> runAsyncWithAop<R>({
  required AopContext context,
  required FutureOr<R> Function() invoke,
  AopHooks? localHooks,
}) async {
  final hooks = _collectHooks(context, localHooks);
  final aroundInterceptors = _collectAroundInterceptors(hooks);

  // Core invocation includes before/invoke/after/onError
  Future<R> coreInvocation() async {
    final annotation = context.annotation;

    if (annotation.before) {
      await _runAsyncHooks(hooks, (hook) => hook.before, context);
    }

    if (context.skipInvocation) {
      context.markSuccess();
      if (annotation.after) {
        await _runAsyncHooks(hooks, (hook) => hook.after, context);
      }
      _throwIfError(context);
      return _result<R>(context);
    }

    try {
      final result = await Future<R>.sync(invoke);
      context.result = result;
      context.markSuccess();
      if (annotation.after) {
        await _runAsyncHooks(hooks, (hook) => hook.after, context);
      }
      _throwIfError(context);
      return _result<R>(context);
    } catch (error, stackTrace) {
      context.error = error;
      context.stackTrace = stackTrace;
      context.markError();
      if (annotation.onError) {
        await _runAsyncHooks(hooks, (hook) => hook.onError, context);
      }

      if (!context.hasError) {
        // Error was cleared in onError hook - recovered
        context.markSuccess();
        if (annotation.after) {
          await _runAsyncHooks(hooks, (hook) => hook.after, context);
        }
        _throwIfError(context);
        return _result<R>(context);
      }

      _throwIfError(context);
      rethrow; // Unreachable but keeps analyzer happy.
    }
  }

  // If no around interceptors, run core directly
  if (aroundInterceptors.isEmpty) {
    return coreInvocation();
  }

  // Build and execute around chain
  final result = await _runAsyncAroundChain(
    context: context,
    interceptors: aroundInterceptors,
    coreInvocation: coreInvocation,
  );
  return result as R;
}

/// Runs the around chain for async methods.
Future<dynamic> _runAsyncAroundChain({
  required AopContext context,
  required List<AroundInterceptor> interceptors,
  required Future<dynamic> Function() coreInvocation,
}) async {
  var currentIndex = 0;

  Future<dynamic> proceed() async {
    if (currentIndex >= interceptors.length) {
      // All around interceptors executed, run core invocation
      return coreInvocation();
    }

    final interceptor = interceptors[currentIndex];
    currentIndex++;

    // Set up proceed callback for this interceptor
    context.setProceed(proceed);

    try {
      final result = await Future.sync(() => interceptor(context));
      return result;
    } finally {
      context.clearProceed();
    }
  }

  return proceed();
}

/// Executes a synchronous method with AOP hooks.
///
/// Note: Around hooks for sync methods must also be synchronous.
/// If an around hook returns a Future, a [StateError] is thrown.
///
/// Example:
/// ```dart
/// final result = runSyncWithAop<int>(
///   context: context,
///   invoke: () => originalMethod(),
///   localHooks: customHooks,
/// );
/// ```
R runSyncWithAop<R>({
  required AopContext context,
  required R Function() invoke,
  AopHooks? localHooks,
}) {
  final hooks = _collectHooks(context, localHooks);
  final aroundInterceptors = _collectAroundInterceptors(hooks);

  // Core invocation includes before/invoke/after/onError
  R coreInvocation() {
    final annotation = context.annotation;

    if (annotation.before) {
      _runSyncHooks(hooks, (hook) => hook.before, context);
    }

    if (context.skipInvocation) {
      context.markSuccess();
      if (annotation.after) {
        _runSyncHooks(hooks, (hook) => hook.after, context);
      }
      _throwIfError(context);
      return _result<R>(context);
    }

    try {
      final result = invoke();
      context.result = result;
      context.markSuccess();
      if (annotation.after) {
        _runSyncHooks(hooks, (hook) => hook.after, context);
      }
      _throwIfError(context);
      return _result<R>(context);
    } catch (error, stackTrace) {
      context.error = error;
      context.stackTrace = stackTrace;
      context.markError();
      if (annotation.onError) {
        _runSyncHooks(hooks, (hook) => hook.onError, context);
      }

      if (!context.hasError) {
        // Error was cleared in onError hook - recovered
        context.markSuccess();
        if (annotation.after) {
          _runSyncHooks(hooks, (hook) => hook.after, context);
        }
        _throwIfError(context);
        return _result<R>(context);
      }

      _throwIfError(context);
      rethrow; // Unreachable but keeps analyzer happy.
    }
  }

  // If no around interceptors, run core directly
  if (aroundInterceptors.isEmpty) {
    return coreInvocation();
  }

  // Build and execute around chain (sync)
  final result = _runSyncAroundChain(
    context: context,
    interceptors: aroundInterceptors,
    coreInvocation: coreInvocation,
  );
  return result as R;
}

/// Runs the around chain for sync methods.
///
/// Throws [StateError] if any around interceptor returns a Future.
dynamic _runSyncAroundChain({
  required AopContext context,
  required List<AroundInterceptor> interceptors,
  required dynamic Function() coreInvocation,
}) {
  var currentIndex = 0;

  dynamic proceed() {
    if (currentIndex >= interceptors.length) {
      // All around interceptors executed, run core invocation
      return coreInvocation();
    }

    final interceptor = interceptors[currentIndex];
    currentIndex++;

    // Set up proceed callback for this interceptor
    context.setProceed(proceed);

    try {
      final result = interceptor(context);
      if (result is Future) {
        throw StateError(
          'Async around hooks are not supported for synchronous methods '
          '(${context.className}.${context.methodName}). '
          'Mark the method as async or use a synchronous around hook.',
        );
      }
      return result;
    } finally {
      context.clearProceed();
    }
  }

  return proceed();
}
