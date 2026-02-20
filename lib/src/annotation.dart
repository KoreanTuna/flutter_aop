import 'pointcut.dart';

/// Annotation that marks a method as an AOP pointcut.
///
/// Attach this to a class method to have a proxy generated inside
/// the `*.aop.dart` part file. Generated proxies execute registered
/// hooks before/after the original method call and optionally when
/// errors occur.
///
/// Example:
/// ```dart
/// class UserService {
///   @Aop(tag: 'auth', description: 'Authenticate user')
///   Future<User> login(String email, String password) async {
///     // implementation
///   }
/// }
/// ```
class Aop {
  /// Creates an [Aop] annotation with the specified options.
  const Aop({
    this.before = true,
    this.after = true,
    this.onError = true,
    this.tag,
    this.description,
  });

  /// Whether `before` hooks should run before the original method call.
  final bool before;

  /// Whether `after` hooks should run after the original method call.
  final bool after;

  /// Whether `onError` hooks should run when the original method throws.
  final bool onError;

  /// Optional tag used to filter hooks.
  ///
  /// When `null`, hooks registered without a tag are executed.
  final String? tag;

  /// Human readable description of why the hook exists.
  final String? description;
}

/// Marks a class as an aspect definition similar to Spring's `@Aspect`.
///
/// Every method annotated with [Before], [After], [OnError], or [Around]
/// will be registered automatically and triggered for matching [Aop] tags.
///
/// Example:
/// ```dart
/// @Aspect(tag: 'auth', order: 1)
/// class SecurityAspect {
///   @Before()
///   void checkAuth(AopContext ctx) {
///     // authentication check
///   }
/// }
/// ```
class Aspect {
  /// Creates an [Aspect] annotation.
  const Aspect({
    this.tag,
    this.order = 0,
  });

  /// Default tag applied to every advice within this aspect unless overridden.
  final String? tag;

  /// Execution order for this aspect. Lower values run first.
  ///
  /// Default is 0. Aspects with the same order run in registration order.
  ///
  /// Example:
  /// ```dart
  /// @Aspect(order: 1)  // Runs first
  /// class SecurityAspect { ... }
  ///
  /// @Aspect(order: 2)  // Runs second
  /// class LoggingAspect { ... }
  /// ```
  final int order;
}

/// Runs the annotated method before the join point executes.
///
/// The advice method must accept exactly one [AopContext] parameter.
///
/// Example:
/// ```dart
/// @Before(tag: 'auth')
/// void logBefore(AopContext ctx) {
///   print('Before ${ctx.methodName}');
/// }
///
/// // Using pointcut instead of tag
/// @Before(pointcut: Pointcut(classPattern: '*Service'))
/// void logAllServices(AopContext ctx) {
///   print('Calling service method: ${ctx.methodName}');
/// }
/// ```
class Before {
  /// Creates a [Before] advice annotation.
  const Before({
    this.tag,
    this.pointcut,
  });

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;

  /// Pointcut expression for pattern-based matching.
  ///
  /// When specified, this advice applies to all methods matching the pointcut
  /// criteria, regardless of tag.
  final Pointcut? pointcut;
}

/// Runs the annotated method after the join point completes successfully.
///
/// The advice method must accept exactly one [AopContext] parameter.
/// At this point, `ctx.result` contains the method's return value.
///
/// Example:
/// ```dart
/// @After(tag: 'auth')
/// void logAfter(AopContext ctx) {
///   print('After ${ctx.methodName}, result: ${ctx.result}');
/// }
/// ```
class After {
  /// Creates an [After] advice annotation.
  const After({
    this.tag,
    this.pointcut,
  });

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;

  /// Pointcut expression for pattern-based matching.
  final Pointcut? pointcut;
}

/// Runs the annotated method when the join point throws.
///
/// The advice method must accept exactly one [AopContext] parameter.
/// At this point, `ctx.error` and `ctx.stackTrace` contain the exception info.
///
/// To recover from the error, set `ctx.error = null` and optionally set
/// `ctx.result` to a fallback value.
///
/// Example:
/// ```dart
/// @OnError(tag: 'auth')
/// void handleError(AopContext ctx) {
///   print('Error in ${ctx.methodName}: ${ctx.error}');
///   // Recover by clearing error and setting fallback
///   ctx.error = null;
///   ctx.result = 'fallback value';
/// }
/// ```
class OnError {
  /// Creates an [OnError] advice annotation.
  const OnError({
    this.tag,
    this.pointcut,
  });

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;

  /// Pointcut expression for pattern-based matching.
  final Pointcut? pointcut;
}

/// Wraps around the join point, controlling when the original method executes.
///
/// This is the most powerful advice type. The advice method must:
/// 1. Accept exactly one [AopContext] parameter
/// 2. Call `ctx.proceed()` to execute the original method (optional)
/// 3. Return the result (either from proceed() or a custom value)
///
/// Use cases:
/// - Performance timing
/// - Caching (skip proceed() and return cached value)
/// - Transaction management
/// - Retry logic
///
/// Example:
/// ```dart
/// @Around(tag: 'timing')
/// Future<dynamic> measureTime(AopContext ctx) async {
///   final stopwatch = Stopwatch()..start();
///   try {
///     // Call the original method
///     final result = await ctx.proceed();
///     return result;
///   } finally {
///     stopwatch.stop();
///     print('${ctx.methodName} took ${stopwatch.elapsedMilliseconds}ms');
///   }
/// }
///
/// // Caching example - skip original method entirely
/// @Around(tag: 'cached')
/// Future<dynamic> cacheAdvice(AopContext ctx) async {
///   final key = '${ctx.methodName}_${ctx.positionalArguments}';
///   final cached = cache[key];
///   if (cached != null) {
///     return cached;  // Return cached value without calling proceed()
///   }
///   final result = await ctx.proceed();
///   cache[key] = result;
///   return result;
/// }
/// ```
class Around {
  /// Creates an [Around] advice annotation.
  const Around({
    this.tag,
    this.pointcut,
  });

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;

  /// Pointcut expression for pattern-based matching.
  final Pointcut? pointcut;
}
