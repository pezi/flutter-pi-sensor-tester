// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:isolate/isolates/isolate_helper.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';
import 'dashboard_abstract.dart';

class DashboardCozIR extends Dashboard {
  const DashboardCozIR({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    var temperature = values['t']! as double;
    var humidity = values['h']! as double;
    var co2 = values['co2']! as int;
    var counter = values['c'] as int;

    var widgetMap = <int, Widget>{};

    widgetMap[0] = Thermometer(
        key: const ValueKey("0"), imageVersion: 5, temperature: temperature);
    widgetMap[1] = Hygrometer(
        key: const ValueKey("1"), imageVersion: 5, humidity: humidity);
    widgetMap[2] = CO2(key: const ValueKey("2"), imageVersion: 2, co2: co2);
    widgetMap[3] = SensorImageBox(
      key: const ValueKey("3"),
      sensor: "Sensor: BME680",
      interface: "serial",
      icon: 'co2_v2.png',
      counter: counter,
    );
    widgetMap[4] = const Clock(key: ValueKey("4"));
    return widgetMap;
  }
}
