// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';
import '../components/sensor_painter.dart';

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the SGP30 sensor data.
Map<int, Widget> buildSGP30(Map<String, dynamic> values) {
  var co2 = values['co2']! as int;
  var voc = values['voc']! as int;
  var ethanol = values['ethanol']! as int;
  var h2 = values['h2']! as int;
  var counter = values['c'] as int;
  var i2c = values['i2c'] as int;

  var widgetMap = <int, Widget>{};

  widgetMap[0] = CO2(key: const ValueKey("0"), imageVersion: 2, co2: co2);
  widgetMap[1] = CustomSensorValue(
    key: const ValueKey("1"),
    value: voc,
    customBackgroundColor: Colors.orange,
    customBorderColor: Colors.black87,
    unit: "voc",
  );
  widgetMap[2] =
      Ethanol(key: const ValueKey("2"), imageVersion: 1, ethanol: ethanol);
  widgetMap[3] = H2(key: const ValueKey("3"), imageVersion: 2, h2: h2);
  widgetMap[4] = SensorImageBox(
    key: const ValueKey("4"),
    sensor: "Sensor: SGP30",
    interface: "I2C Bus: $i2c}",
    icon: 'iaq_v1.png',
    counter: counter,
  );
  widgetMap[5] = const Clock(key: ValueKey("5"));
  return widgetMap;
}
