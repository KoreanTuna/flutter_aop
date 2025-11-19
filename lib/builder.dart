import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/aop_generator.dart';

Builder aopBuilder(BuilderOptions options) =>
    PartBuilder([AopGenerator()], '.aop.dart');
