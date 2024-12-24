// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'isolate_helper.dart';

class DemoIsolate extends IsolateWrapper {
  int counter = 0;
  int duration;
  bool durationChanged = false;

  DemoIsolate(super.isolateId, super.data) : duration = data as int;
  DemoIsolate.empty()
      : duration = 0,
        super.empty();

  @override
  void processData(SendPort sendPort, Object data) {
    if (data is int) {
      duration += data;
      durationChanged = true;
    } else if (data is String) {
      if (data == 'exit') {
        exit(0);
      } else if (data == 'quit') {
        Isolate.exit();
      }
    }
  }

  @override
  InitTaskResult init() {
    if (sensorDebug) {
      print('Isolate init task: $duration');
    }

    return InitTaskResult("{}", {"counter": counter, "duration": duration});
  }

  @override
  Future<MainTaskResult> main(String json) async {
    try {
      ++counter;
      // sleep(Duration(seconds: duration));

      for (var i = 0; i < duration * 2; ++i) {
        // sleep(const Duration(microseconds: 500));
        await Future.delayed(const Duration(milliseconds: 500));

        if (durationChanged) {
          durationChanged = false;
          break;
        }
      }

      return MainTaskResult(false, {"counter": counter, "duration": duration});
    } catch (e) {
      if (sensorDebug) {
        print('Sensor error: $e');
      }
      return MainTaskResult.error(true, e.toString());
    }
  }
}
