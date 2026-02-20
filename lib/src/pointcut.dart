import 'package:meta/meta.dart';

/// Defines a pointcut expression for matching methods.
///
/// Pointcuts allow you to specify which methods an advice should apply to
/// based on patterns rather than explicit tags.
///
/// Supports glob-style patterns with `*` (matches any characters) and
/// `?` (matches single character) wildcards.
///
/// Example:
/// ```dart
/// // Match all methods in classes ending with "Service"
/// const servicePointcut = Pointcut(classPattern: '*Service');
///
/// // Match all getter methods
/// const getterPointcut = Pointcut(methodPattern: 'get*');
///
/// // Match find methods in Repository classes
/// const findPointcut = Pointcut(
///   classPattern: '*Repository',
///   methodPattern: 'find*',
/// );
/// ```
@immutable
class Pointcut {
  /// Creates a pointcut with the given matching criteria.
  ///
  /// At least one of [classPattern], [methodPattern], or [tag] should be
  /// specified for the pointcut to be useful.
  const Pointcut({
    this.classPattern,
    this.methodPattern,
    this.tag,
  });

  /// Glob pattern for class names.
  ///
  /// Examples:
  /// - `*Service` - matches UserService, LoginService, etc.
  /// - `User*` - matches UserService, UserRepository, etc.
  /// - `*Repository*` - matches UserRepositoryImpl, etc.
  final String? classPattern;

  /// Glob pattern for method names.
  ///
  /// Examples:
  /// - `get*` - matches getUser, getData, etc.
  /// - `find*ById` - matches findUserById, findOrderById, etc.
  /// - `*Async` - matches fetchAsync, loadAsync, etc.
  final String? methodPattern;

  /// Tag to match (existing behavior).
  ///
  /// When specified, only methods annotated with `@Aop(tag: ...)` matching
  /// this tag will be matched.
  final String? tag;

  /// Tests if this pointcut matches the given class name, method name, and tag.
  ///
  /// All specified criteria must match (AND logic):
  /// - If [classPattern] is specified, the class name must match
  /// - If [methodPattern] is specified, the method name must match
  /// - If [tag] is specified, the annotation tag must match
  bool matches({
    required String className,
    required String methodName,
    String? annotationTag,
  }) {
    // Tag matching
    if (tag != null && annotationTag != tag) {
      return false;
    }

    // Class pattern matching
    if (classPattern != null && !_matchesGlob(classPattern!, className)) {
      return false;
    }

    // Method pattern matching
    if (methodPattern != null && !_matchesGlob(methodPattern!, methodName)) {
      return false;
    }

    return true;
  }

  /// Simplified glob matching (supports * and ? wildcards).
  static bool _matchesGlob(String pattern, String value) {
    // Convert glob to regex:
    // - Escape regex special characters except * and ?
    // - * becomes .*
    // - ? becomes .
    final buffer = StringBuffer('^');
    for (var i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      switch (char) {
        case '*':
          buffer.write('.*');
        case '?':
          buffer.write('.');
        case '.':
        case '+':
        case '^':
        case r'$':
        case '(':
        case ')':
        case '[':
        case ']':
        case '{':
        case '}':
        case '|':
        case r'\':
          buffer.write(r'\');
          buffer.write(char);
        default:
          buffer.write(char);
      }
    }
    buffer.write(r'$');

    final regex = RegExp(buffer.toString(), caseSensitive: true);
    return regex.hasMatch(value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Pointcut) return false;
    return classPattern == other.classPattern &&
        methodPattern == other.methodPattern &&
        tag == other.tag;
  }

  @override
  int get hashCode => Object.hash(classPattern, methodPattern, tag);

  @override
  String toString() {
    final parts = <String>[];
    if (classPattern != null) parts.add('class: $classPattern');
    if (methodPattern != null) parts.add('method: $methodPattern');
    if (tag != null) parts.add('tag: $tag');
    return 'Pointcut(${parts.join(', ')})';
  }
}

/// Convenience factory for common pointcut patterns.
///
/// These pre-defined pointcuts can be used directly or combined with
/// custom patterns.
class Pointcuts {
  Pointcuts._();

  /// Matches all methods in classes ending with "Service".
  static const Pointcut allServices = Pointcut(classPattern: '*Service');

  /// Matches all methods in classes ending with "Repository".
  static const Pointcut allRepositories = Pointcut(classPattern: '*Repository');

  /// Matches all methods in classes ending with "Controller".
  static const Pointcut allControllers = Pointcut(classPattern: '*Controller');

  /// Matches all methods starting with "get".
  static const Pointcut allGetters = Pointcut(methodPattern: 'get*');

  /// Matches all methods starting with "set".
  static const Pointcut allSetters = Pointcut(methodPattern: 'set*');

  /// Matches all methods starting with "find".
  static const Pointcut allFinders = Pointcut(methodPattern: 'find*');

  /// Matches all methods starting with "fetch" or "load".
  static const Pointcut fetchOperations = Pointcut(methodPattern: 'fetch*');

  /// Matches all methods starting with "load".
  static const Pointcut loadOperations = Pointcut(methodPattern: 'load*');

  /// Matches all methods starting with "save".
  static const Pointcut saveOperations = Pointcut(methodPattern: 'save*');

  /// Matches all methods starting with "delete".
  static const Pointcut deleteOperations = Pointcut(methodPattern: 'delete*');
}
