import 'context.dart';
import 'hooks.dart';
import 'ordered_hooks.dart';
import 'pointcut.dart';

/// Global registry that proxies consult when dispatching hooks.
///
/// The registry stores hooks in two ways:
/// 1. Tag-based: hooks registered with a specific tag or globally (null tag)
/// 2. Pointcut-based: hooks registered with pattern matching criteria
///
/// When resolving hooks for a method call, both tag-based and pointcut-based
/// hooks are considered and returned in order of their [order] value.
///
/// Example:
/// ```dart
/// // Register global hook (applies to all @Aop methods)
/// AopRegistry.instance.register(
///   AopHooks(before: (ctx) => print('Global before')),
/// );
///
/// // Register tag-specific hook
/// AopRegistry.instance.register(
///   AopHooks(before: (ctx) => print('Auth before')),
///   tag: 'auth',
///   order: 1,
/// );
///
/// // Register pointcut-based hook
/// AopRegistry.instance.registerWithPointcut(
///   AopHooks(before: (ctx) => print('Service before')),
///   pointcut: Pointcut(classPattern: '*Service'),
/// );
/// ```
class AopRegistry {
  AopRegistry._();

  /// Singleton access to the registry.
  static final AopRegistry instance = AopRegistry._();

  /// Tag-based hooks stored with ordering information.
  final Map<String?, List<OrderedHooks>> _orderedHooksByTag = {};

  /// Pointcut-based hooks.
  final List<_PointcutHooks> _pointcutHooks = [];

  int _nextSequence = 0;

  /// Registers [hooks] for the provided [tag] with optional ordering.
  ///
  /// When [tag] is `null`, the hooks are considered global and are invoked
  /// for every annotated method.
  ///
  /// The [order] parameter controls execution order. Lower values run first.
  /// Default is 0. Hooks with the same order run in registration order.
  void register(AopHooks hooks, {String? tag, int order = 0}) {
    final entries = _orderedHooksByTag.putIfAbsent(tag, () => <OrderedHooks>[]);
    entries.add(
      OrderedHooks(hooks: hooks, order: order, sequence: _nextSequence++),
    );
    // Keep sorted by order
    entries.sort(compareOrderedHooks);
  }

  /// Registers [hooks] with a pointcut expression for pattern-based matching.
  ///
  /// The [pointcut] defines which methods this hook applies to based on
  /// class name patterns, method name patterns, or tags.
  ///
  /// The [order] parameter controls execution order relative to other hooks.
  void registerWithPointcut(
    AopHooks hooks, {
    required Pointcut pointcut,
    int order = 0,
  }) {
    _pointcutHooks.add(
      _PointcutHooks(
        pointcut: pointcut,
        hooks: OrderedHooks(
          hooks: hooks,
          order: order,
          sequence: _nextSequence++,
        ),
      ),
    );
    // Keep sorted by order
    _pointcutHooks.sort((a, b) => compareOrderedHooks(a.hooks, b.hooks));
  }

  /// Removes all registered hooks. Useful for testing.
  void clear() {
    _orderedHooksByTag.clear();
    _pointcutHooks.clear();
    _nextSequence = 0;
  }

  /// Resolves hooks for a particular tag.
  ///
  /// Global hooks (`null` tag) are returned first, followed by hooks
  /// for the specific tag. All hooks are sorted by their order value.
  ///
  /// This method does NOT include pointcut-based hooks. Use [resolveForContext]
  /// when you have full context information.
  Iterable<AopHooks> resolve(String? tag) sync* {
    final allHooks = <OrderedHooks>[];

    // Collect global hooks
    final globalHooks = _orderedHooksByTag[null];
    if (globalHooks != null) {
      allHooks.addAll(globalHooks);
    }

    // Collect tagged hooks
    if (tag != null) {
      final taggedHooks = _orderedHooksByTag[tag];
      if (taggedHooks != null) {
        allHooks.addAll(taggedHooks);
      }
    }

    // Sort by order and yield
    allHooks.sort(compareOrderedHooks);
    for (final oh in allHooks) {
      yield oh.hooks;
    }
  }

  /// Resolves all applicable hooks for a given context.
  ///
  /// This includes:
  /// 1. Global hooks (null tag)
  /// 2. Tag-specific hooks matching the annotation's tag
  /// 3. Pointcut-based hooks matching the context
  ///
  /// All hooks are sorted by their order value.
  Iterable<AopHooks> resolveForContext(AopContext context) sync* {
    final allHooks = <OrderedHooks>[];
    final tag = context.annotation.tag;

    // Collect global hooks
    final globalHooks = _orderedHooksByTag[null];
    if (globalHooks != null) {
      allHooks.addAll(globalHooks);
    }

    // Collect tagged hooks
    if (tag != null) {
      final taggedHooks = _orderedHooksByTag[tag];
      if (taggedHooks != null) {
        allHooks.addAll(taggedHooks);
      }
    }

    // Collect pointcut-based hooks that match
    for (final ph in _pointcutHooks) {
      if (ph.pointcut.matches(
        className: context.className,
        methodName: context.methodName,
        annotationTag: tag,
      )) {
        allHooks.add(ph.hooks);
      }
    }

    // Sort by order and yield
    allHooks.sort(compareOrderedHooks);
    for (final oh in allHooks) {
      yield oh.hooks;
    }
  }

  /// Returns the number of registered tag-based hooks.
  int get tagBasedHookCount {
    var count = 0;
    for (final list in _orderedHooksByTag.values) {
      count += list.length;
    }
    return count;
  }

  /// Returns the number of registered pointcut-based hooks.
  int get pointcutHookCount => _pointcutHooks.length;
}

/// Internal class to associate a pointcut with its hooks.
class _PointcutHooks {
  const _PointcutHooks({required this.pointcut, required this.hooks});

  final Pointcut pointcut;
  final OrderedHooks hooks;
}
