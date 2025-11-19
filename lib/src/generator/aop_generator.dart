import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Generates proxy classes and aspect registrations.
class AopGenerator extends Generator {
  static const _annotationLibrary = 'package:flutter_aop/src/annotation.dart';
  static const _contextLibrary = 'package:flutter_aop/src/context.dart';

  static const TypeChecker _aopChecker = TypeChecker.fromUrl(
    '$_annotationLibrary#Aop',
  );
  static const TypeChecker _aspectChecker = TypeChecker.fromUrl(
    '$_annotationLibrary#Aspect',
  );
  static const TypeChecker _beforeChecker = TypeChecker.fromUrl(
    '$_annotationLibrary#Before',
  );
  static const TypeChecker _afterChecker = TypeChecker.fromUrl(
    '$_annotationLibrary#After',
  );
  static const TypeChecker _onErrorChecker = TypeChecker.fromUrl(
    '$_annotationLibrary#OnError',
  );
  static const TypeChecker _contextChecker = TypeChecker.fromUrl(
    '$_contextLibrary#AopContext',
  );

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) {
    final buffer = StringBuffer();
    final proxies = <_ProxyInfo>[];
    final aspects = <_AspectInfo>[];

    for (final classElement in library.classes) {
      if (_shouldSkipClass(classElement)) continue;

      final methods = classElement.methods
          .where((method) => !method.isStatic && !method.isPrivate)
          .toList();
      final hasAnnotatedMethod = methods.any(
        (method) =>
            _aopChecker.hasAnnotationOf(method, throwOnUnresolved: false),
      );

      if (!hasAnnotatedMethod) continue;

      buffer
        ..writeln(_generateProxyClass(classElement, methods))
        ..writeln();

      if (classElement.typeParameters.isEmpty) {
        proxies.add(
          _ProxyInfo(
            className: classElement.displayName,
            proxyName: '${classElement.displayName}AopProxy',
          ),
        );
      }
    }

    for (final classElement in library.classes) {
      final aspectInfo = _buildAspect(classElement);
      if (aspectInfo != null) {
        aspects.add(aspectInfo);
      }
    }

    if (proxies.isNotEmpty || aspects.isNotEmpty) {
      buffer
        ..writeln(
          _generateInitializationBlock(
            proxies: proxies,
            aspects: aspects,
            buildStep: buildStep,
          ),
        )
        ..writeln();
    }

    final output = buffer.toString().trim();
    if (output.isEmpty) {
      return null;
    }
    return '$output\n';
  }

  bool _shouldSkipClass(ClassElement element) {
    final name = element.name;
    return element.isAbstract ||
        name == null ||
        name.isEmpty ||
        element.isPrivate;
  }

  String _generateProxyClass(
    ClassElement element,
    List<MethodElement> methods,
  ) {
    final buffer = StringBuffer();
    final className = element.displayName;
    final typeParams = _typeParameters(element);
    final typeArgs = _typeArguments(element);
    final proxyName = '${className}AopProxy';

    buffer
      ..writeln('class $proxyName$typeParams implements $className$typeArgs {')
      ..writeln('  $proxyName(this._target, {AopHooks? hooks})')
      ..writeln('      : _localHooks = hooks;')
      ..writeln()
      ..writeln('  final $className$typeArgs _target;')
      ..writeln('  final AopHooks? _localHooks;');

    final accessors = <PropertyAccessorElement>[
      ...element.getters,
      ...element.setters,
    ].where((accessor) => !accessor.isStatic && !accessor.isPrivate);

    for (final accessor in accessors) {
      buffer
        ..writeln()
        ..writeln(_generateAccessor(accessor));
    }

    for (final method in methods) {
      buffer
        ..writeln()
        ..writeln(_generateMethod(element, method));
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateAccessor(PropertyAccessorElement accessor) {
    final returnType = accessor.returnType.getDisplayString();
    final fieldName = accessor.displayName;
    if (accessor is GetterElement) {
      return [
        '  @override',
        '  $returnType get $fieldName => _target.$fieldName;',
      ].join('\n');
    }

    final setter = accessor as SetterElement;
    final parameterType = setter.formalParameters.first.type.getDisplayString();
    return [
      '  @override',
      '  set $fieldName($parameterType value) => _target.$fieldName = value;',
    ].join('\n');
  }

  String _generateMethod(ClassElement element, MethodElement method) {
    final annotationValue = _aopChecker.firstAnnotationOf(
      method,
      throwOnUnresolved: false,
    );
    final annotationLiteral = _annotationLiteral(annotationValue);
    final hasAnnotation = annotationValue != null;
    final returnType = method.returnType.getDisplayString();
    final methodName = method.name ?? method.displayName;
    final descriptionName = method.displayName;
    final parameters = method.formalParameters;
    final signature = _parameterSignature(parameters);
    final callArguments = _methodArguments(parameters);
    final positionalArgsList = _positionalArgumentsLiteral(parameters);
    final namedArgsMap = _namedArgumentsLiteral(parameters);
    final description = '$returnType $descriptionName($signature)'
        .trim()
        .replaceAll('\n', ' ');

    final buffer = StringBuffer()
      ..writeln('  @override')
      ..write('  $returnType $methodName($signature)');

    if (!hasAnnotation) {
      buffer.writeln(' => _target.$methodName($callArguments);');
      return buffer.toString();
    }

    final isAsync = _returnsFuture(method.returnType);
    final dispatcher = isAsync ? 'runAsyncWithAop' : 'runSyncWithAop';
    final typeArg = _methodResultType(method.returnType);
    final invocation = '_target.$methodName($callArguments)';

    buffer
      ..writeln(' {')
      ..writeln('    const annotation = $annotationLiteral;')
      ..writeln('    final context = AopContext(')
      ..writeln("      target: _target,")
      ..writeln("      className: '${element.displayName}',")
      ..writeln("      methodName: '$methodName',")
      ..writeln('      annotation: annotation,')
      ..writeln('      positionalArguments: $positionalArgsList,')
      ..writeln('      namedArguments: $namedArgsMap,')
      ..writeln('    );');

    if (isAsync) {
      buffer
        ..writeln('    return $dispatcher<$typeArg>(')
        ..writeln('      context: context,')
        ..writeln('      localHooks: _localHooks,')
        ..writeln('      invoke: () => $invocation,')
        ..writeln('    );');
    } else {
      final returnKeyword = returnType == 'void' ? '' : 'return ';
      buffer
        ..writeln('    $returnKeyword$dispatcher<$typeArg>(')
        ..writeln('      context: context,')
        ..writeln('      localHooks: _localHooks,')
        ..writeln('      invoke: () => $invocation,')
        ..writeln('    );');
    }
    buffer
      ..writeln('  }')
      ..writeln('  // Proxy for: $description');

    return buffer.toString();
  }

  _AspectInfo? _buildAspect(ClassElement element) {
    if (!_aspectChecker.hasAnnotationOf(element, throwOnUnresolved: false)) {
      return null;
    }
    if (element.isAbstract) {
      throw InvalidGenerationSourceError(
        '@Aspect classes must be concrete: ${element.displayName}',
        element: element,
      );
    }

    final annotation = _aspectChecker.firstAnnotationOf(
      element,
      throwOnUnresolved: false,
    );
    final defaultTag = annotation?.getField('tag')?.toStringValue();

    final constructor = element.unnamedConstructor;
    if (constructor != null) {
      final hasRequiredParam = constructor.formalParameters.any(
        (param) => !param.isOptional && !param.hasDefaultValue,
      );
      if (hasRequiredParam) {
        throw InvalidGenerationSourceError(
          'Aspect ${element.displayName} must provide an unnamed constructor '
          'without required parameters.',
          element: element,
        );
      }
    }

    final instantiation = constructor == null
        ? '${element.displayName}()'
        : constructor.isConst
        ? 'const ${element.displayName}()'
        : '${element.displayName}()';

    final advices = <_AdviceInfo>[];
    for (final method in element.methods.where(
      (method) => !method.isStatic && !method.isPrivate,
    )) {
      void addAdvice(TypeChecker checker, _AdviceType type) {
        final data = checker.firstAnnotationOf(
          method,
          throwOnUnresolved: false,
        );
        if (data == null) return;
        _validateAdviceSignature(element, method);
        advices.add(
          _AdviceInfo(
            methodName: method.name ?? method.displayName,
            type: type,
            tag: data.getField('tag')?.toStringValue() ?? defaultTag,
          ),
        );
      }

      addAdvice(_beforeChecker, _AdviceType.before);
      addAdvice(_afterChecker, _AdviceType.after);
      addAdvice(_onErrorChecker, _AdviceType.onError);
    }

    if (advices.isEmpty) {
      return null;
    }

    return _AspectInfo(
      className: element.displayName,
      instantiation: instantiation,
      advices: advices,
    );
  }

  void _validateAdviceSignature(ClassElement aspect, MethodElement method) {
    if (method.formalParameters.length != 1) {
      throw InvalidGenerationSourceError(
        'Advice method ${aspect.displayName}.${method.displayName} must accept '
        'exactly one AopContext parameter.',
        element: method,
      );
    }

    final parameter = method.formalParameters.first;
    if (!_contextChecker.isAssignableFromType(parameter.type)) {
      throw InvalidGenerationSourceError(
        'Advice method ${aspect.displayName}.${method.displayName} must accept '
        'AopContext as the only parameter.',
        element: method,
      );
    }
  }

  String _generateInitializationBlock({
    required List<_ProxyInfo> proxies,
    required List<_AspectInfo> aspects,
    required BuildStep buildStep,
  }) {
    if (proxies.isEmpty && aspects.isEmpty) {
      return '';
    }
    final identifier = _sanitizeIdentifier(buildStep.inputId.path);
    final initializedField = '_\$flutterAopInitialized_$identifier';
    final initFunction = '_\$flutterAopEnsureInitialized_$identifier';
    final bootstrapField = '_\$flutterAopBootstrap_$identifier';
    final publicBootstrap = 'flutterAopBootstrap$identifier';
    final buffer = StringBuffer()
      ..writeln('bool $initializedField = false;')
      ..writeln('bool $initFunction() {')
      ..writeln('  if ($initializedField) {')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  $initializedField = true;');

    if (proxies.isNotEmpty) {
      buffer.writeln('  final proxyRegistry = AopProxyRegistry.instance;');
      for (final proxy in proxies) {
        buffer.writeln(
          '  proxyRegistry.register<${proxy.className}>(('
          '${proxy.className} target, {AopHooks? hooks}) => '
          '${proxy.proxyName}(target, hooks: hooks),'
          ');',
        );
      }
    }

    if (aspects.isNotEmpty) {
      buffer.writeln('  final hookRegistry = AopRegistry.instance;');
      for (var i = 0; i < aspects.length; i++) {
        final aspect = aspects[i];
        buffer.writeln('  final aspect$i = ${aspect.instantiation};');
        for (final advice in aspect.advices) {
          final hookField = _adviceField(advice.type);
          final tagLiteral = advice.tag == null
              ? ''
              : 'tag: ${literalString(advice.tag!)}';
          buffer
            ..writeln('  hookRegistry.register(')
            ..writeln(
              '    AopHooks($hookField: aspect$i.${advice.methodName}),',
            );
          if (tagLiteral.isNotEmpty) {
            buffer.writeln('    $tagLiteral,');
          }
          buffer.writeln('  );');
        }
      }
    }

    buffer
      ..writeln('  return true;')
      ..writeln('}')
      ..writeln('@pragma(\'vm:entry-point\', \'flutter_aop_bootstrap\')')
      ..writeln(
        'final bool $bootstrapField = '
        'AopBootstrapper.instance.register($initFunction);',
      )
      ..writeln('void $publicBootstrap() {')
      ..writeln('  // ignore: unused_local_variable')
      ..writeln('  final bool _ = $bootstrapField;')
      ..writeln('}');

    return buffer.toString();
  }

  String _adviceField(_AdviceType type) {
    switch (type) {
      case _AdviceType.before:
        return 'before';
      case _AdviceType.after:
        return 'after';
      case _AdviceType.onError:
        return 'onError';
    }
  }

  bool _returnsFuture(DartType type) {
    return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
  }

  String _methodResultType(DartType type) {
    if (type is VoidType) return 'void';
    if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        return type.typeArguments.first.getDisplayString();
      }
      return 'dynamic';
    }
    if (type is TypeParameterType) {
      return type.getDisplayString();
    }
    return type.getDisplayString();
  }

  String _typeParameters(ClassElement element) {
    if (element.typeParameters.isEmpty) return '';
    final params = element.typeParameters
        .map((param) {
          final bound = param.bound == null
              ? ''
              : ' extends ${param.bound!.getDisplayString()}';
          final name = param.displayName;
          return '$name$bound';
        })
        .join(', ');
    return '<$params>';
  }

  String _typeArguments(ClassElement element) {
    if (element.typeParameters.isEmpty) return '';
    final args = element.typeParameters
        .map((param) => param.displayName)
        .join(', ');
    return '<$args>';
  }

  String _parameterSignature(List<FormalParameterElement> parameters) {
    final required = parameters
        .where((param) => param.isRequiredPositional)
        .map(_formatParameter)
        .toList();
    final optionalPositional = parameters
        .where((param) => param.isOptionalPositional)
        .map(_formatParameter)
        .toList();
    final named = parameters
        .where((param) => param.isNamed)
        .map(_formatParameter)
        .toList();

    final chunks = <String>[];
    if (required.isNotEmpty) {
      chunks.add(required.join(', '));
    }
    if (optionalPositional.isNotEmpty) {
      chunks.add('[${optionalPositional.join(', ')}]');
    }
    if (named.isNotEmpty) {
      chunks.add('{${named.join(', ')}}');
    }
    return chunks.join(', ');
  }

  String _formatParameter(FormalParameterElement parameter) {
    final modifier = StringBuffer();
    if (parameter.isRequiredNamed) {
      modifier.write('required ');
    }
    if (parameter.isCovariant) {
      modifier.write('covariant ');
    }
    final type = parameter.type.getDisplayString();
    final defaultValue = parameter.hasDefaultValue
        ? ' = ${parameter.defaultValueCode}'
        : '';
    return '$modifier$type ${parameter.displayName}$defaultValue';
  }

  String _methodArguments(List<FormalParameterElement> parameters) {
    final chunks = <String>[];
    for (final param in parameters) {
      if (param.isNamed) {
        final name = param.name ?? param.displayName;
        chunks.add('$name: ${param.displayName}');
      } else {
        chunks.add(param.displayName);
      }
    }
    return chunks.join(', ');
  }

  String _positionalArgumentsLiteral(List<FormalParameterElement> parameters) {
    final positional = parameters
        .where((param) => param.isPositional)
        .map((param) => param.displayName)
        .join(', ');
    if (positional.isEmpty) {
      return 'const <dynamic>[]';
    }
    return '<dynamic>[$positional]';
  }

  String _namedArgumentsLiteral(List<FormalParameterElement> parameters) {
    final named = parameters.where((param) => param.isNamed).toList();
    if (named.isEmpty) {
      return 'const <String, dynamic>{}';
    }

    final entries = named
        .map((param) {
          final name = param.name ?? param.displayName;
          return "'$name': ${param.displayName}";
        })
        .join(', ');
    return '<String, dynamic>{$entries}';
  }

  String _annotationLiteral(DartObject? annotation) {
    if (annotation == null) {
      return 'Aop()';
    }
    final before = annotation.getField('before')?.toBoolValue() ?? true;
    final after = annotation.getField('after')?.toBoolValue() ?? true;
    final onError = annotation.getField('onError')?.toBoolValue() ?? true;
    final tag = annotation.getField('tag')?.toStringValue();
    final description = annotation.getField('description')?.toStringValue();

    final buffer = StringBuffer('Aop(')
      ..write('before: $before, ')
      ..write('after: $after, ')
      ..write('onError: $onError');

    if (tag != null) {
      buffer.write(", tag: ${literalString(tag)}");
    }
    if (description != null) {
      buffer.write(", description: ${literalString(description)}");
    }
    buffer.write(')');
    return buffer.toString();
  }
}

String literalString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

String _sanitizeIdentifier(String input) {
  final buffer = StringBuffer();
  for (final codeUnit in input.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    if (RegExp(r'[A-Za-z0-9_]').hasMatch(char)) {
      buffer.write(char);
    } else {
      buffer.write('_');
    }
  }
  return buffer.toString();
}

class _ProxyInfo {
  const _ProxyInfo({required this.className, required this.proxyName});

  final String className;
  final String proxyName;
}

class _AspectInfo {
  const _AspectInfo({
    required this.className,
    required this.instantiation,
    required this.advices,
  });

  final String className;
  final String instantiation;
  final List<_AdviceInfo> advices;
}

class _AdviceInfo {
  const _AdviceInfo({
    required this.methodName,
    required this.type,
    required this.tag,
  });

  final String methodName;
  final _AdviceType type;
  final String? tag;
}

enum _AdviceType { before, after, onError }
