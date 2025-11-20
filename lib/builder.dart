import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/aop_generator.dart';

const _generatedFileHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// dart format width=80
''';

Builder aopBuilder(BuilderOptions options) => PartBuilder(
      [AopGenerator()],
      '.aop.dart',
      header: _generatedFileHeader,
    );
