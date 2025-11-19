import 'hooks.dart';

/// Global registry that proxies consult when dispatching hooks.
class AopRegistry {
  AopRegistry._();

  /// Singleton access to the registry.
  static final AopRegistry instance = AopRegistry._();

  final Map<String?, List<AopHooks>> _hooksByTag = {};

  /// Registers [hooks] for the provided [tag].
  ///
  /// When [tag] is `null`, the hooks are considered global and are invoked
  /// for every annotated method.
  void register(AopHooks hooks, {String? tag}) {
    final entries = _hooksByTag.putIfAbsent(tag, () => <AopHooks>[]);
    entries.add(hooks);
  }

  /// Removes all registered hooks. Useful for testing.
  void clear() => _hooksByTag.clear();

  /// Resolves hooks for a particular tag. Global hooks (`null`) are returned
  /// first, followed by hooks for the specific tag.
  Iterable<AopHooks> resolve(String? tag) sync* {
    final globalHooks = _hooksByTag[null];
    if (globalHooks != null) {
      yield* globalHooks;
    }
    if (tag != null) {
      final taggedHooks = _hooksByTag[tag];
      if (taggedHooks != null) {
        yield* taggedHooks;
      }
    }
  }
}
