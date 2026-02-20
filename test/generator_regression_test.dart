import 'dart:io';

import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generator_fixture.dart';

void main() {
  setUpAll(() {
    flutterAopBootstraptest_generator_fixture_dart();
    ensureAllAopInitialized();
  });

  setUp(() {
    GeneratorPointcutAspect.reset();
    GeneratorGenericAspect.reset();
  });

  test(
    'pointcut advice is generated via registerWithPointcut and tag merge',
    () {
      final service = aopWrap(GeneratorPointcutService());
      service.findById('a');
      service.findOther('b');

      expect(GeneratorPointcutAspect.calls, ['before findById']);
    },
  );

  test('generic methods keep type parameters in generated proxy', () {
    final service = aopWrap(GeneratorGenericService());
    final value = service.echo<int>(3);

    expect(value, 3);
    expect(GeneratorGenericAspect.calls, ['before echo']);
  });

  test(
    'generated file contains pointcut registration and generic signature',
    () async {
      final content = await File(
        'test/generator_fixture.aop.dart',
      ).readAsString();

      expect(content, contains('registerWithPointcut'));
      expect(content, contains("classPattern: '*Service'"));
      expect(content, contains("methodPattern: 'find*'"));
      expect(content, contains("tag: 'audit'"));
      expect(content, contains('T echo<T extends Object>(T value)'));
      expect(content, contains('_target.echo<T>(value)'));
    },
  );
}
