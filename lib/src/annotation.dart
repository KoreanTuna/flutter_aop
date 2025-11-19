/// Annotation that marks a method as an AOP pointcut.
///
/// Attach this to a class method to have a proxy generated inside
/// the `*.aop.dart` part file. Generated proxies execute registered
/// hooks before/after the original method call and optionally when
/// errors occur.
class Aop {
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
/// Every method annotated with [Before], [After], or [OnError] will be
/// registered automatically and triggered for matching [Aop] tags.
class Aspect {
  const Aspect({this.tag});

  /// Default tag applied to every advice within this aspect unless overridden.
  final String? tag;
}

/// Runs the annotated method before the join point executes.
class Before {
  const Before({this.tag});

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;
}

/// Runs the annotated method after the join point completes successfully.
class After {
  const After({this.tag});

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;
}

/// Runs the annotated method when the join point throws.
class OnError {
  const OnError({this.tag});

  /// Tag to match against `@Aop(tag: ...)`.
  final String? tag;
}
