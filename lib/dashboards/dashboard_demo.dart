// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';

import '../components/clock.dart';
import '../components/timer_demo_box.dart';
import '../isolates/isolate_helper.dart';
import 'dashboard_multiple_streams_abstract.dart';

// for a complete rebuild, e.g. tab change store here the latest value of the data stream
var _oldCounter1 = 0;
var _oldCounter2 = 0;
var _oldCounter3 = 0;

class DashboardDemo extends DashboardMultipleStreams {
  DashboardDemo(
      {super.key, required super.isolateWrappers, required super.initResults});

  @override
  Map<int, Widget> buildUI(List<TaskResult> result) {
    var counter1 = max(result[0].data!['counter'] as int, _oldCounter1);
    _oldCounter1 = counter1;

    var counter2 = max(result[1].data!['counter'] as int, _oldCounter2);
    _oldCounter2 = counter2;

    var counter3 = max(result[2].data!['counter'] as int, _oldCounter3);
    _oldCounter3 = counter3;

    var duration1 = result[0].data!['duration'];
    var duration2 = result[1].data!['duration'];
    var duration3 = result[2].data!['duration'];

    var widgetMap = <int, Widget>{};

    widgetMap[0] = TimerDemoBox(
        isolateId: "demo1",
        key: const ValueKey("0"),
        color: Colors.green,
        counter: counter1,
        duration: duration1,
        text: "Isolate timer 1");

    widgetMap[1] = TimerDemoBox(
      key: const ValueKey("1"),
      color: Colors.blue,
      counter: counter2,
      duration: duration2,
      text: "Isolate timer 2",
      isolateId: 'demo2',
    );

    widgetMap[2] = TimerDemoBox(
        key: const ValueKey("2"),
        color: Colors.amber,
        counter: counter3,
        duration: duration3,
        text: "Isolate timer 3",
        isolateId: 'demo3');

    widgetMap[3] = const Clock(key: ValueKey("3"));
    return widgetMap;
  }
}
