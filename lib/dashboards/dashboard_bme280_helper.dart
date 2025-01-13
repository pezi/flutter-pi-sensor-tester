// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the BME280 sensor data.
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
