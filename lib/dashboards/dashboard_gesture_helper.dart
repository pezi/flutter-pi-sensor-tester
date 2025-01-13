// Copyright (c) 2025, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/sensor_image_box.dart';
// avoid Flutter class clash
import '../components/sensor_box.dart' as sensor_box;

// An independent file to make this code usable for Flutter web without relying
// on the dart_periphery dependency!

/// Returns a map of widgets which contains the gesture sensor data.
Map<int, Widget> buildGesture(Map<String, dynamic> values) {
  var gestureName = values['gesture_name'] as String;
  var gestureIndex = values['gesture_index'] as int;
  var counter = values['c'] as int;
  var i2c = values['i2c'] as int;
  var widgetMap = <int, Widget>{};

  widgetMap[0] = sensor_box.GestureDetector(
    key: const ValueKey("0"),
    imageVersion: 1,
    gesture: gestureName,
    index: gestureIndex,
  );
  widgetMap[1] = SensorImageBox(
    key: const ValueKey("1"),
    sensor: "Grove Gesture Sensor",
    interface: "I2C Bus: $i2c}",
    icon: 'gesture_v2.png',
    counter: counter,
  );
  widgetMap[2] = const Clock(key: ValueKey("2"));
  return widgetMap;
}
