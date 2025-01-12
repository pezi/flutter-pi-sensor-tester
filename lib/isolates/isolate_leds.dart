// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

import 'package:dart_periphery/dart_periphery.dart';

import '../components/led_box.dart';
import '../dart_constants.dart';
import '../demo_config.dart';
import 'isolate_helper.dart';

Map<LedColor, GPIO> gpioMap = {};

class LedsIsolate extends IsolateWrapper {
  LedsIsolate(String isolateId, String initialData)
      : super(isolateId, initialData, IsolateModel.listener) {
    DemoConfig().update(initialData);
  }
  LedsIsolate.empty() : super.empty();

  @override
  void processData(SendPort sendPort, Object data) {
    DemoConfig config = DemoConfig();

    if (data is String) {
      if (!config.isSimulation()) {
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

    if (!!config.isSimulation()) {
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

    DemoConfig config = DemoConfig();
    if (!(config.isSimulation())) {
      try {
        var leds = config.getLeds();
        gpioMap[LedColor.red] = GPIO(leds[0], GPIOdirection.gpioDirOut);
        gpioMap[LedColor.yellow] = GPIO(leds[1], GPIOdirection.gpioDirOut);
        gpioMap[LedColor.green] = GPIO(leds[2], GPIOdirection.gpioDirOut);
        return InitTaskResult("{}", {});
      } catch (e) {
        return InitTaskResult.error(e.toString());
      }
    } else {
      return InitTaskResult('', {"c": 0, "status": false});
    }
  }
}
