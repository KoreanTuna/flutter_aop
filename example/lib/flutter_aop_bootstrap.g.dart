// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_aop_example/aspect/logging_aspect.dart' as _i0;
import 'package:flutter_aop_example/aspect/metrics_aspect.dart' as _i1;
import 'package:flutter_aop_example/login_service.dart' as _i2;

bool _flutterAopBootstrapRan = false;
void runFlutterAopBootstrap() {
  if (_flutterAopBootstrapRan) {
    return;
  }
  _flutterAopBootstrapRan = true;
  _i0.flutterAopBootstraplib_aspect_logging_aspect_dart();
  _i1.flutterAopBootstraplib_aspect_metrics_aspect_dart();
  _i2.flutterAopBootstraplib_login_service_dart();
  ensureAllAopInitialized();
}
