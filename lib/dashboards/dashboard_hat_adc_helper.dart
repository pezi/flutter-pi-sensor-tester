// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart';
import '../components/sensor_image_box.dart';

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the hat ADC data.
Map<int, Widget> buildHatADC(Map<String, dynamic> values) {
  var analog = values['a']! as int;
  var counter = values['c'] as int;
  var pin = values['pin'] as int;

  var widgetMap = <int, Widget>{};

  widgetMap[0] = ADC(
    key: const ValueKey("0"),
    imageVersion: 1,
    value: analog,
  );
  widgetMap[1] = SensorImageBox(
    key: const ValueKey("1"),
    sensor: "Sensor    : ADC",
    interface: "Analog Pin: $pin",
    icon: 'converter_v1.png',
    counter: counter,
  );
  widgetMap[2] = const Clock(key: ValueKey("2"));
  return widgetMap;
}
