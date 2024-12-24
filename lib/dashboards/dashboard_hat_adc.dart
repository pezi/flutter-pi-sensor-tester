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

class DashboardHatADC extends Dashboard {
  const DashboardHatADC({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var values = result.data!;
    var analog = values['a']! as int;
    var counter = values['c'] as int;

    var widgetMap = <int, Widget>{};

    widgetMap[0] = ADC(
      key: const ValueKey("0"),
      imageVersion: 1,
      value: analog,
    );
    widgetMap[1] = SensorImageBox(
      key: const ValueKey("1"),
      sensor: "Sensor: ADC",
      interface: "I2C Bus: ${gI2C.toString()}",
      icon: 'converter_v1.png',
      counter: counter,
    );
    widgetMap[2] = const Clock(key: ValueKey("2"));
    return widgetMap;
  }
}
