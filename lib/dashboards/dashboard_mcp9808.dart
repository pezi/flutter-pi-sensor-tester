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

class DashboardMCP9808 extends Dashboard {
  const DashboardMCP9808({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    var temperature = values['t']! as double;
    var counter = values['c'] as int;
    var i2c = values['i2c'] as int;
    var widgetMap = <int, Widget>{};

    widgetMap[0] = Thermometer(
        key: const ValueKey("0"), imageVersion: 5, temperature: temperature);
    widgetMap[1] = SensorImageBox(
      key: const ValueKey("1"),
      sensor: "Sensor: MCP9808",
      interface: "I2C Bus: $i2c}",
      icon: 'thermometer_v5.png',
      counter: counter,
    );
    widgetMap[2] = const Clock(key: ValueKey("2"));
    return widgetMap;
  }
}
