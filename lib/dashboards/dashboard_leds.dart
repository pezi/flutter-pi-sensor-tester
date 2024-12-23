// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/components/led_box.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';

import '../components/clock.dart';
import 'dashboard_abstract.dart';

class DashboardLeds extends Dashboard {
  const DashboardLeds({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    var widgetMap = <int, Widget>{};

    widgetMap[0] = LedBox(
      key: const ValueKey("0"),
      counter: gLedCounter[LedColor.red] as int,
      color: LedColor.red,
      label: "Led red",
      status: gLedStatus[LedColor.red] as bool,
      isolateId: isolateWrapper.isolateId,
    );

    widgetMap[1] = LedBox(
      key: const ValueKey("1"),
      counter: gLedCounter[LedColor.yellow] as int,
      color: LedColor.yellow,
      label: "Led yellow",
      status: gLedStatus[LedColor.yellow] as bool,
      isolateId: isolateWrapper.isolateId,
    );

    widgetMap[2] = LedBox(
      key: const ValueKey("2"),
      counter: gLedCounter[LedColor.green] as int,
      color: LedColor.green,
      label: "Led green",
      status: gLedStatus[LedColor.green] as bool,
      isolateId: isolateWrapper.isolateId,
    );

    widgetMap[3] = const Clock(key: ValueKey("3"));
    return widgetMap;
  }
}
