// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';

import '../components/clock.dart';
import '../components/sensor_box.dart' as sensor_box;
import '../components/sensor_image_box.dart';
import 'dashboard_abstract.dart';

class DashboardGesture extends Dashboard {
  const DashboardGesture({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    var gesture = Gesture.values[values['gesture']! as int];
    var counter = values['c'] as int;
    var i2c = values['i2c'] as int;
    var widgetMap = <int, Widget>{};

    widgetMap[0] = sensor_box.GestureDetector(
      key: const ValueKey("0"),
      imageVersion: 1,
      gesture: gesture.name,
      index: gesture.index,
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
}
