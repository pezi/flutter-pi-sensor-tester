// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:isolate/isolates/isolate_gesture.dart';

import 'isolate_bme280.dart';
import 'isolate_bme680.dart';
import 'isolate_cozir.dart';
import 'isolate_demo.dart';
import 'isolate_helper.dart';
import 'isolate_leds.dart';
import 'isolate_mcp9808.dart';
import 'isolate_mlx90615.dart';
import 'isolate_sdc30.dart';
import 'isolate_sgp30.dart';
import 'isolate_sht31.dart';

/// Constructs a class by name.
class IsolateClassFactory {
  static final Map<String,
      IsolateWrapper Function(String isolateId, Object data)> _constructors = {
    BME680isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            BME680isolate(isolateId, data as bool),
    BME280isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            BME280isolate(isolateId, data as bool),
    SHT31isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            SHT31isolate(isolateId, data as bool),
    SGP30isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            SGP30isolate(isolateId, data as bool),
    MCP9808isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            MCP9808isolate(isolateId, data as bool),
    MLX90615isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            MLX90615isolate(isolateId, data as bool),
    GestureDetectorIsolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            GestureDetectorIsolate(isolateId, data as bool),
    CozIRisolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            CozIRisolate(isolateId, data as bool),
    LedsIsolate.empty().runtimeType.toString():
        (String isolateId, Object data) => LedsIsolate(isolateId, data as bool),
    DemoIsolate.empty().runtimeType.toString():
        (String isolateId, Object data) => DemoIsolate(isolateId, data),
    SDC30isolate.empty().runtimeType.toString():
        (String isolateId, Object data) =>
            SDC30isolate(isolateId, data as bool),
  };

  static IsolateWrapper createInstance(
      String className, String isolateId, Object data) {
    var constructor = _constructors[className];
    if (constructor != null) {
      return constructor(isolateId, data);
    } else {
      throw Exception("Class not found: $className");
    }
  }
}
