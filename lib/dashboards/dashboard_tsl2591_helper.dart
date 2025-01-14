// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the TSL2591 sensor data.
Map<int, Widget> buildTSL2591(Map<String, dynamic> values) {
  var visible = values['visible']! as int;
  var infrared = values['ir']! as int;
  var lux = values['lux']! as int;
  var full = values['full']! as int;
  var counter = values['c'] as int;
  var i2c = values['i2c'] as int;

  var widgetMap = <int, Widget>{};

  widgetMap[0] = VisibleLight(
    key: const ValueKey("0"),
    imageVersion: 2,
    visible: visible,
    showUnit: false,
  );
  widgetMap[1] = Infrared(
      key: const ValueKey("1"),
      imageVersion: 1,
      infrared: infrared,
      showUnit: false);

  widgetMap[2] =
      Spectrum(key: const ValueKey("2"), imageVersion: 1, spectrum: full);

  widgetMap[3] = Lux(key: const ValueKey("3"), imageVersion: 1, lux: lux);

  widgetMap[4] = SensorImageBox(
    key: const ValueKey("4"),
    sensor: "Sensor: TSL2591",
    interface: "I2C Bus: $i2c",
    icon: 'spectrum_v2.png',
    counter: counter,
  );
  widgetMap[5] = const Clock(key: ValueKey("5"));
  return widgetMap;
}