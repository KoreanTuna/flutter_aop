import 'dart:async';
import 'context.dart';
import 'hooks.dart';
import 'registry.dart';

List<AopHooks> _collectHooks(String? tag, AopHooks? localHooks) {
  final hooks = <AopHooks>[];
  if (localHooks != null) {
    hooks.add(localHooks);
  }
  hooks.addAll(AopRegistry.instance.resolve(tag));
  return hooks;
}

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

R _result<R>(AopContext context) => context.result as R;

void _throwIfError(AopContext context) {
  if (!context.hasError) return;
  Error.throwWithStackTrace(
    context.error!,
    context.stackTrace ?? StackTrace.current,
  );
}

Future<R> runAsyncWithAop<R>({
  required AopContext context,
  required FutureOr<R> Function() invoke,
  AopHooks? localHooks,
}) async {
  final hooks = _collectHooks(context.annotation.tag, localHooks);
  final annotation = context.annotation;

  if (annotation.before) {
    await _runAsyncHooks(hooks, (hook) => hook.before, context);
  }

  if (context.skipInvocation) {
    if (annotation.after) {
      await _runAsyncHooks(hooks, (hook) => hook.after, context);
    }
    _throwIfError(context);
    return _result<R>(context);
  }

  try {
    final result = await Future<R>.sync(invoke);
    context.result = result;
    if (annotation.after) {
      await _runAsyncHooks(hooks, (hook) => hook.after, context);
    }
    _throwIfError(context);
    return _result<R>(context);
  } catch (error, stackTrace) {
    context.error = error;
    context.stackTrace = stackTrace;
    if (annotation.onError) {
      await _runAsyncHooks(hooks, (hook) => hook.onError, context);
    }

    if (!context.hasError) {
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

R runSyncWithAop<R>({
  required AopContext context,
  required R Function() invoke,
  AopHooks? localHooks,
}) {
  final hooks = _collectHooks(context.annotation.tag, localHooks);
  final annotation = context.annotation;

  if (annotation.before) {
    _runSyncHooks(hooks, (hook) => hook.before, context);
  }

  if (context.skipInvocation) {
    if (annotation.after) {
      _runSyncHooks(hooks, (hook) => hook.after, context);
    }
    _throwIfError(context);
    return _result<R>(context);
  }

  try {
    final result = invoke();
    context.result = result;
    if (annotation.after) {
      _runSyncHooks(hooks, (hook) => hook.after, context);
    }
    _throwIfError(context);
    return _result<R>(context);
  } catch (error, stackTrace) {
    context.error = error;
    context.stackTrace = stackTrace;
    if (annotation.onError) {
      _runSyncHooks(hooks, (hook) => hook.onError, context);
    }

    if (!context.hasError) {
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
