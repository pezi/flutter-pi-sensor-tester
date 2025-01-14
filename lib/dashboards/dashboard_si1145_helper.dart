// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the SI1145 sensor data.
Map<int, Widget> buildSI1145(Map<String, dynamic> values) {
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
