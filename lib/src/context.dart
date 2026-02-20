import 'dart:async';

import 'annotation.dart';

/// Callback type for proceeding with the original method invocation.
typedef ProceedCallback = FutureOr<dynamic> Function();

/// Represents the current state of method execution.
enum AopExecutionState {
  /// Before the method has been invoked.
  beforeInvocation,

  /// Method is currently executing (within proceed()).
  executing,

  /// Method completed successfully.
  afterSuccess,

  /// Method threw an exception.
  afterError,

  /// Execution was skipped via skipInvocation.
  skipped,
}

/// Details about the method invocation being intercepted.
///
/// This context object is passed to all advice methods and contains:
/// - Information about the target method (class name, method name, arguments)
/// - The annotation configuration
/// - Methods to control execution flow (proceed, skip, modify result)
/// - Access to the execution result or error after invocation
///
/// Example usage in @Before advice:
/// ```dart
/// @Before()
/// void logBefore(AopContext ctx) {
///   print('Calling ${ctx.className}.${ctx.methodName}');
///   print('Arguments: ${ctx.positionalArguments}');
/// }
/// ```
///
/// Example usage in @Around advice:
/// ```dart
/// @Around()
/// Future<dynamic> timing(AopContext ctx) async {
///   final sw = Stopwatch()..start();
///   try {
///     return await ctx.proceed();
///   } finally {
///     print('${ctx.methodName} took ${sw.elapsedMilliseconds}ms');
///   }
/// }
/// ```
class AopContext {
  /// Creates an [AopContext] with the required invocation details.
  AopContext({
    required this.target,
    required this.className,
    required this.methodName,
    required this.annotation,
    required this.positionalArguments,
    required this.namedArguments,
  }) : invocationId = _nextInvocationId++,
       startedAt = DateTime.now();

  static int _nextInvocationId = 1;

  // ========== Immutable Properties ==========

  /// Unique identifier for this invocation.
  final int invocationId;

  /// Timestamp captured when this context is created.
  final DateTime startedAt;

  /// Instance whose method is being executed.
  final Object target;

  /// Class name where the hook lives.
  final String className;

  /// Method name that triggered the hook.
  final String methodName;

  /// Annotation data captured from source.
  final Aop annotation;

  /// Positional arguments passed to the method.
  final List<dynamic> positionalArguments;

  /// Named arguments passed to the method.
  final Map<String, dynamic> namedArguments;

  // ========== Execution State ==========

  AopExecutionState _state = AopExecutionState.beforeInvocation;

  /// Current execution state.
  AopExecutionState get state => _state;

  // ========== Result Management ==========

  /// Result returned from the wrapped method.
  ///
  /// This value is set after the method completes successfully,
  /// or can be set manually in advice methods to override the result.
  dynamic result;

  /// Returns the result cast to type [T].
  ///
  /// Throws [TypeError] if the result is not of type [T].
  T getResult<T>() => result as T;

  // ========== Error Management ==========

  /// Error thrown by the wrapped method.
  ///
  /// This is set when the method throws an exception.
  /// In @OnError advice, you can set this to `null` to recover from the error.
  Object? error;

  /// Stack trace captured for [error].
  StackTrace? stackTrace;

  /// True if the wrapped call threw an error.
  bool get hasError => error != null;

  /// Returns the error cast to type [T], or null if no error or type mismatch.
  T? getError<T>() => error is T ? error as T : null;

  // ========== Per-Invocation Attributes ==========

  final Map<String, dynamic> _attributes = <String, dynamic>{};

  /// Stores an attribute for this invocation context.
  void setAttribute(String key, dynamic value) {
    _attributes[key] = value;
  }

  /// Retrieves an attribute by [key] cast to [T], or null if missing.
  T? getAttribute<T>(String key) {
    final value = _attributes[key];
    if (value == null && !_attributes.containsKey(key)) {
      return null;
    }
    return value as T?;
  }

  /// Returns true if an attribute exists for [key].
  bool hasAttribute(String key) => _attributes.containsKey(key);

  /// Removes and returns the attribute for [key], if present.
  dynamic removeAttribute(String key) => _attributes.remove(key);

  // ========== Execution Control ==========

  bool _skipInvocation = false;

  /// When true, skips invoking the original method.
  ///
  /// Before hooks can set this (and optionally [result]) to short-circuit
  /// execution - useful for cache hits or feature-flagged bypasses.
  bool get skipInvocation => _skipInvocation;

  /// Sets whether to skip the original method invocation.
  ///
  /// @deprecated Use [skipWithResult] instead for better clarity.
  @Deprecated('Use skipWithResult() instead for better clarity')
  set skipInvocation(bool value) {
    _skipInvocation = value;
    if (value) {
      _state = AopExecutionState.skipped;
    }
  }

  /// Skips the original method invocation and returns [returnValue] instead.
  ///
  /// This is a cleaner alternative to setting [skipInvocation] and [result]
  /// separately.
  ///
  /// Example:
  /// ```dart
  /// @Before()
  /// void cacheCheck(AopContext ctx) {
  ///   final cached = cache.get(ctx.positionalArguments);
  ///   if (cached != null) {
  ///     ctx.skipWithResult(cached);
  ///   }
  /// }
  /// ```
  void skipWithResult(dynamic returnValue) {
    _skipInvocation = true;
    result = returnValue;
    _state = AopExecutionState.skipped;
  }

  // ========== @Around Support ==========

  ProceedCallback? _proceed;

  /// Whether this context supports proceed() (i.e., within @Around advice).
  bool get canProceed => _proceed != null;

  /// Proceeds with the original method invocation.
  ///
  /// This can only be called from an @Around advice.
  /// After calling proceed(), the result is available via [result].
  ///
  /// Returns the result of the original method (or the value set by
  /// subsequent advice in the chain).
  ///
  /// Example:
  /// ```dart
  /// @Around()
  /// Future<dynamic> timing(AopContext ctx) async {
  ///   final sw = Stopwatch()..start();
  ///   try {
  ///     return await ctx.proceed();
  ///   } finally {
  ///     print('${ctx.methodName} took ${sw.elapsedMilliseconds}ms');
  ///   }
  /// }
  /// ```
  ///
  /// Throws [StateError] if called outside of an @Around advice context.
  FutureOr<dynamic> proceed() {
    if (_proceed == null) {
      throw StateError(
        'proceed() can only be called from an @Around advice. '
        'Current advice type does not support proceed().',
      );
    }
    _state = AopExecutionState.executing;
    return _proceed!();
  }

  /// Internal: Sets the proceed callback. Used by the runner.
  void setProceed(ProceedCallback callback) {
    _proceed = callback;
  }

  /// Internal: Clears the proceed callback after use.
  void clearProceed() {
    _proceed = null;
  }

  /// Internal: Updates the state after successful execution.
  void markSuccess() {
    _state = AopExecutionState.afterSuccess;
  }

  /// Internal: Updates the state after error.
  void markError() {
    _state = AopExecutionState.afterError;
  }

  // ========== Utility Methods ==========

  /// Gets a positional argument by index with type casting.
  ///
  /// Throws [RangeError] if index is out of bounds.
  /// Throws [TypeError] if the argument is not of type [T].
  T getArg<T>(int index) => positionalArguments[index] as T;

  /// Gets a named argument with type casting.
  ///
  /// Throws if the argument doesn't exist or is not of type [T].
  T getNamedArg<T>(String name) => namedArguments[name] as T;

  /// Gets a named argument with type casting, or returns [defaultValue] if not found.
  T getNamedArgOr<T>(String name, T defaultValue) {
    final value = namedArguments[name];
    if (value == null && !namedArguments.containsKey(name)) {
      return defaultValue;
    }
    return value as T;
  }

  /// Returns a human-readable description of the join point.
  String get joinPointDescription => '$className.$methodName';

  @override
  String toString() {
    return 'AopContext('
        'invocationId: $invocationId, '
        'joinPoint: $joinPointDescription, '
        'state: $state, '
        'args: $positionalArguments, '
        'result: $result, '
        'error: $error)';
  }
}
