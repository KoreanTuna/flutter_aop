import 'annotation.dart';

/// Details about the method invocation being intercepted.
class AopContext {
  AopContext({
    required this.target,
    required this.className,
    required this.methodName,
    required this.annotation,
    required this.positionalArguments,
    required this.namedArguments,
  });

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

  /// Result returned from the wrapped method.
  dynamic result;

  /// Error thrown by the wrapped method.
  Object? error;

  /// Stack trace captured for [error].
  StackTrace? stackTrace;

  /// True if the wrapped call threw.
  bool get hasError => error != null;
}
