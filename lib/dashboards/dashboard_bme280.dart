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

Map<int, Widget> buildBME280(Map<String, dynamic> values) {
  var temperature = values['t']! as double;
  var pressure = values['p']! as double;
  var humidity = values['h']! as double;

  var counter = values['c'] as int;
  var i2c = values['i2c'] as int;
  var widgetMap = <int, Widget>{};

  widgetMap[0] = Thermometer(
      key: const ValueKey("0"), imageVersion: 5, temperature: temperature);
  widgetMap[1] =
      Barometer(key: const ValueKey("1"), imageVersion: 1, pressure: pressure);
  widgetMap[2] =
      Hygrometer(key: const ValueKey("2"), imageVersion: 5, humidity: humidity);
  widgetMap[3] = SensorImageBox(
    key: const ValueKey("3"),
    sensor: "Sensor: BME280",
    interface: "I2C Bus: $i2c",
    icon: 'sensor_v3.png',
    counter: counter,
  );
  widgetMap[4] = const Clock(key: ValueKey("4"));
  return widgetMap;
}

class DashboardBME280 extends Dashboard {
  const DashboardBME280({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    return buildBME280(values);
  }
}
