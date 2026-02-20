import 'package:meta/meta.dart';

import 'hooks.dart';

/// Wraps [AopHooks] with ordering information for controlling execution order.
///
/// When multiple aspects are registered for the same tag, their execution
/// order is determined by the [order] value. Lower values execute first.
///
/// Example:
/// ```dart
/// // Security aspect runs first (order: 1)
/// // Logging aspect runs second (order: 2)
/// // Metrics aspect runs last (order: 3)
/// ```
@immutable
class OrderedHooks {
  /// Creates an [OrderedHooks] instance.
  const OrderedHooks({required this.hooks, this.order = 0, this.sequence = 0});

  /// The actual hooks to execute.
  final AopHooks hooks;

  /// Execution order. Lower values execute first.
  ///
  /// Default is 0. Hooks with the same order execute in registration order.
  final int order;

  /// Registration sequence used as a deterministic tie-breaker.
  ///
  /// Lower values were registered earlier and execute first when [order]
  /// values are the same.
  final int sequence;

  @override
  String toString() =>
      'OrderedHooks(order: $order, sequence: $sequence, hooks: $hooks)';
}

/// Compares [OrderedHooks] by their order for sorting.
///
/// Returns negative if [a] should execute before [b],
/// positive if [a] should execute after [b],
/// zero if they have the same order.
int compareOrderedHooks(OrderedHooks a, OrderedHooks b) {
  final orderCompare = a.order.compareTo(b.order);
  if (orderCompare != 0) {
    return orderCompare;
  }
  return a.sequence.compareTo(b.sequence);
}
