// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';
import '../dart_constants.dart';
import 'dashboard_abstract.dart';

class DashboardSI1145 extends Dashboard {
  const DashboardSI1145({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    var visible = values['visible']! as int;
    var infrared = values['ir']! as int;
    var uvIndex = values['uvIndex']! as double;
    var i2c = values['i2c'] as int;
    var counter = values['c'] as int;

    var widgetMap = <int, Widget>{};

    widgetMap[0] = VisibleLight(
        key: const ValueKey("0"), imageVersion: 2, visible: visible);
    widgetMap[1] =
        Infrared(key: const ValueKey("1"), imageVersion: 1, infrared: infrared);
    widgetMap[2] =
        UVindex(key: const ValueKey("2"), imageVersion: 1, uvIndex: uvIndex);
    widgetMap[3] = SensorImageBox(
      key: const ValueKey("3"),
      sensor: "Sensor: SI1145",
      interface: "I2C Bus: $i2c",
      icon: 'light_v1.png',
      counter: counter,
    );
    widgetMap[4] = const Clock(key: ValueKey("4"));
    return widgetMap;
  }
}
