import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

/// Aggregates all generated AOP bootstrap functions into a single entry point.
class AopBootstrapBuilder implements Builder {
  const AopBootstrapBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$package$': ['lib/flutter_aop_bootstrap.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final metas = <_BootstrapMeta>[];
    await for (final asset in buildStep.findAssets(Glob('**.aop.dart'))) {
      final meta = _metaFromAsset(asset);
      if (meta != null) {
        metas.add(meta);
      }
    }
    metas.sort((a, b) {
      final importCompare = a.importUri.compareTo(b.importUri);
      if (importCompare != 0) return importCompare;
      return a.functionName.compareTo(b.functionName);
    });

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: type=lint')
      ..writeln()
      ..writeln("import 'package:flutter_aop/flutter_aop.dart';");

    final importAliases = <String, String>{};
    var importIndex = 0;
    for (final meta in metas) {
      if (importAliases.containsKey(meta.importUri)) continue;
      final alias = '_i$importIndex';
      importAliases[meta.importUri] = alias;
      importIndex += 1;
      buffer.writeln("import '${meta.importUri}' as $alias;");
    }

    buffer
      ..writeln()
      ..writeln('bool _flutterAopBootstrapRan = false;')
      ..writeln('void runFlutterAopBootstrap() {')
      ..writeln('  if (_flutterAopBootstrapRan) {')
      ..writeln('    return;')
      ..writeln('  }')
      ..writeln('  _flutterAopBootstrapRan = true;');

    for (final meta in metas) {
      final alias = importAliases[meta.importUri]!;
      buffer.writeln('  $alias.${meta.functionName}();');
    }

    buffer
      ..writeln('  ensureAllAopInitialized();')
      ..writeln('}');

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/flutter_aop_bootstrap.g.dart'),
      buffer.toString(),
    );
  }
}

class _BootstrapMeta {
  const _BootstrapMeta({required this.importUri, required this.functionName});

  final String importUri;
  final String functionName;
}

Builder aopBootstrapBuilder(BuilderOptions _) => const AopBootstrapBuilder();

_BootstrapMeta? _metaFromAsset(AssetId asset) {
  final path = asset.path;
  if (!path.endsWith('.aop.dart')) {
    return null;
  }
  final original =
      '${path.substring(0, path.length - '.aop.dart'.length)}.dart';
  final identifier = _sanitizeIdentifier(original);
  final importUri = _packageImportUri(asset.package, original);
  if (importUri.isEmpty) return null;
  return _BootstrapMeta(
    importUri: importUri,
    functionName: 'flutterAopBootstrap$identifier',
  );
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

String _packageImportUri(String package, String path) {
  final libIndex = path.indexOf('lib/');
  if (libIndex == -1) {
    return '';
  }
  final relative = path.substring(libIndex + 4);
  return 'package:$package/$relative';
}
