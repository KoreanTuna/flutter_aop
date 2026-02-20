import 'context.dart';
import 'hooks.dart';

/// Observation phase emitted by [createObservationHooks].
enum AopObservationPhase { before, after, error }

/// Sink function for observation events.
typedef AopObservationSink = void Function(AopObservationEvent event);

/// Structured event emitted for AOP method observations.
class AopObservationEvent {
  const AopObservationEvent({
    required this.phase,
    required this.invocationId,
    required this.className,
    required this.methodName,
    required this.tag,
    required this.executionState,
    required this.startedAt,
    required this.timestamp,
    required this.elapsed,
    required this.isSlow,
    this.positionalArguments,
    this.namedArguments,
    this.result,
    this.error,
    this.stackTrace,
  });

  final AopObservationPhase phase;
  final int invocationId;
  final String className;
  final String methodName;
  final String? tag;
  final AopExecutionState executionState;
  final DateTime startedAt;
  final DateTime timestamp;
  final Duration elapsed;
  final bool isSlow;
  final List<dynamic>? positionalArguments;
  final Map<String, dynamic>? namedArguments;
  final dynamic result;
  final Object? error;
  final StackTrace? stackTrace;

  /// Returns "ClassName.methodName" for quick logging.
  String get joinPointDescription => '$className.$methodName';
}

/// Creates hooks that emit structured observation events for every invocation.
///
/// Defaults are privacy-safe:
/// - [includeArguments] is false
/// - [includeResult] is false
/// - [includeStackTrace] is false
AopHooks createObservationHooks({
  required AopObservationSink sink,
  bool includeArguments = false,
  bool includeResult = false,
  bool includeStackTrace = false,
  Duration? slowCallThreshold,
}) {
  AopObservationEvent buildEvent(
    AopContext context,
    AopObservationPhase phase,
  ) {
    final timestamp = DateTime.now();
    final elapsed = timestamp.difference(context.startedAt);
    final isSlow = slowCallThreshold != null && elapsed >= slowCallThreshold;

    final positional = includeArguments
        ? List<dynamic>.unmodifiable(context.positionalArguments)
        : null;
    final named = includeArguments
        ? Map<String, dynamic>.unmodifiable(context.namedArguments)
        : null;

    return AopObservationEvent(
      phase: phase,
      invocationId: context.invocationId,
      className: context.className,
      methodName: context.methodName,
      tag: context.annotation.tag,
      executionState: context.state,
      startedAt: context.startedAt,
      timestamp: timestamp,
      elapsed: elapsed,
      isSlow: isSlow,
      positionalArguments: positional,
      namedArguments: named,
      result: includeResult && phase == AopObservationPhase.after
          ? context.result
          : null,
      error: phase == AopObservationPhase.error ? context.error : null,
      stackTrace: includeStackTrace && phase == AopObservationPhase.error
          ? context.stackTrace
          : null,
    );
  }

  return AopHooks(
    before: (context) => sink(buildEvent(context, AopObservationPhase.before)),
    after: (context) => sink(buildEvent(context, AopObservationPhase.after)),
    onError: (context) => sink(buildEvent(context, AopObservationPhase.error)),
  );
}
