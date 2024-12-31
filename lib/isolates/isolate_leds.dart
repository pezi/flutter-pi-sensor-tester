// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

import 'package:dart_periphery/dart_periphery.dart';

import '../components/led_box.dart';
import '../dart_constants.dart';
import 'isolate_helper.dart';

Map<LedColor, GPIO> gpioMap = {};

class LedsIsolate extends IsolateWrapper {
  LedsIsolate(String isolateId, bool simulation)
      : super(isolateId, simulation, IsolateModel.listener);
  LedsIsolate.empty() : super.empty();

  @override
  void processData(SendPort sendPort, Object data) {
    if (data is String) {
      if (!(initialData as bool)) {
        for (var c in LedColor.values) {
          try {
            gpioMap[c]?.dispose();
          } catch (e) {
            // we can do nothing
          }
        }
      }
      if (data == 'exit') {
        exit(0);
      } else if (data == 'quit') {
        Isolate.exit();
      }
    }
    List<Object?> array = data as List<Object?>;

    if (!(initialData as bool)) {
      gpioMap[LedColor.values[array[0] as int]]?.write(array[1] as bool);
    } else {
      if (gIsolateDebug) {
        print("Set led");
      }
    }

    processMainTaskResult(sendPort, MainTaskResult(false, {}));
  }

  @override
  InitTaskResult init() {
    if (gIsolateDebug) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        gpioMap[LedColor.red] = GPIO(18, GPIOdirection.gpioDirOut);
        gpioMap[LedColor.yellow] = GPIO(16, GPIOdirection.gpioDirOut);
        gpioMap[LedColor.green] = GPIO(5, GPIOdirection.gpioDirOut);
        return InitTaskResult("{}", {});
      } catch (e) {
        return InitTaskResult.error(e.toString());
      }
    } else {
      return InitTaskResult('', {"c": 0, "status": false});
    }
  }
}
