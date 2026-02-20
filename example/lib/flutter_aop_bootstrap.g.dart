// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:flutter_aop/flutter_aop.dart';
import 'package:flutter_aop_example/scenarios/basic_auth/aspect/logging_aspect.dart' as _i0;
import 'package:flutter_aop_example/scenarios/basic_auth/aspect/metrics_aspect.dart' as _i1;
import 'package:flutter_aop_example/scenarios/basic_auth/login_service.dart' as _i2;
import 'package:flutter_aop_example/scenarios/cache/cache_aspect.dart' as _i3;
import 'package:flutter_aop_example/scenarios/cache/cache_service.dart' as _i4;
import 'package:flutter_aop_example/scenarios/ordering/pipeline_order_aspect.dart' as _i5;
import 'package:flutter_aop_example/scenarios/ordering/pipeline_service.dart' as _i6;
import 'package:flutter_aop_example/scenarios/pointcut/repository_pointcut_aspect.dart' as _i7;
import 'package:flutter_aop_example/scenarios/pointcut/repository_service.dart' as _i8;
import 'package:flutter_aop_example/scenarios/recovery/payment_recovery_aspect.dart' as _i9;
import 'package:flutter_aop_example/scenarios/recovery/payment_service.dart' as _i10;
import 'package:flutter_aop_example/scenarios/short_circuit/feature_flag_aspect.dart' as _i11;
import 'package:flutter_aop_example/scenarios/short_circuit/feature_flag_service.dart' as _i12;

bool _flutterAopBootstrapRan = false;
void runFlutterAopBootstrap() {
  if (_flutterAopBootstrapRan) {
    return;
  }
  _flutterAopBootstrapRan = true;
  _i0.flutterAopBootstraplib_scenarios_basic_auth_aspect_logging_aspect_dart();
  _i1.flutterAopBootstraplib_scenarios_basic_auth_aspect_metrics_aspect_dart();
  _i2.flutterAopBootstraplib_scenarios_basic_auth_login_service_dart();
  _i3.flutterAopBootstraplib_scenarios_cache_cache_aspect_dart();
  _i4.flutterAopBootstraplib_scenarios_cache_cache_service_dart();
  _i5.flutterAopBootstraplib_scenarios_ordering_pipeline_order_aspect_dart();
  _i6.flutterAopBootstraplib_scenarios_ordering_pipeline_service_dart();
  _i7.flutterAopBootstraplib_scenarios_pointcut_repository_pointcut_aspect_dart();
  _i8.flutterAopBootstraplib_scenarios_pointcut_repository_service_dart();
  _i9.flutterAopBootstraplib_scenarios_recovery_payment_recovery_aspect_dart();
  _i10.flutterAopBootstraplib_scenarios_recovery_payment_service_dart();
  _i11.flutterAopBootstraplib_scenarios_short_circuit_feature_flag_aspect_dart();
  _i12.flutterAopBootstraplib_scenarios_short_circuit_feature_flag_service_dart();
  ensureAllAopInitialized();
}
