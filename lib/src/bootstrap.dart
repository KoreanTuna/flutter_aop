// ignore_for_file: library_private_types_in_public_api

typedef _Initializer = bool Function();

/// Manages registration of generated initialization callbacks.
class AopBootstrapper {
  AopBootstrapper._();

  static final AopBootstrapper instance = AopBootstrapper._();

  final List<_Initializer> _initializers = <_Initializer>[];
  bool _autoRun = true;

  /// Registers a generated initializer.
  ///
  /// By default the initializer runs immediately when the library is loaded.
  /// Frameworks that want to defer initialization can disable autorun and
  /// invoke [ensureAll] later.
  bool register(_Initializer initializer) {
    if (_autoRun) {
      initializer();
    } else {
      _initializers.add(initializer);
    }
    return true;
  }

  /// Runs every registered initializer exactly once.
  void ensureAll() {
    _autoRun = true;
    while (_initializers.isNotEmpty) {
      final initializer = _initializers.removeLast();
      initializer();
    }
  }

  /// Exposes the number of pending initializers (mainly for debugging/tests).
  int get pendingInitializers => _initializers.length;
}

/// Convenience helper to initialize every generated proxy/aspect.
void ensureAllAopInitialized() => AopBootstrapper.instance.ensureAll();
