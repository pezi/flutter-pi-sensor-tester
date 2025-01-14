// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import '../demo_config.dart';
import 'helper.dart';
import 'isolate_helper.dart';

/// Isolate to handle an analog pin/DAC of am extension hat.
class HatADCisolate extends IsolateWrapper {
  int counter = 1;
  late GroveBaseHat hat;
  late NanoHatHub nanoHat;

  HatADCisolate(super.isolateId, String super.initialData) {
    DemoConfig().update(initialData as String);
  }
  HatADCisolate.empty() : super("", "");

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    DemoConfig config = DemoConfig();
    if (!(config.isSimulation())) {
      try {} on Exception catch (e, s) {
        if (gIsolateDebug) {
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
      } on Error catch (e, s) {
        if (gIsolateDebug) {
          print('Error details:\n $e');
          print('Stack trace:\n $s');
        }
      }
    }
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
  }

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    var values = createDataMap(DashboardType.adc);

    values['c'] = counter;
    var pin = DemoConfig().getAnalogPin();
    values['a'] = hat.readADCraw(pin);
    values['pin'] = pin;
    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = createDataMap(DashboardType.adc);
    values['c'] = counter;
    values['a'] = 100 + Random().nextInt(100);
    var pin = DemoConfig().getAnalogPin();
    values['pin'] = pin;
    return values;
  }

  @override
  InitTaskResult init() {
    if (gIsolateDebug) {
      print('Isolate init task');
    }

    DemoConfig config = DemoConfig();
    // real hardware in use?
    if (!(config.isSimulation())) {
      try {
        hat = GroveBaseHat();
        return InitTaskResult(hat.toJson(), getData());
      } on Exception catch (e, s) {
        if (gIsolateDebug) {
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
        return InitTaskResult.error(e.toString());
      } on Error catch (e, s) {
        if (gIsolateDebug) {
          print('Error details:\n $e');
          print('Stack trace:\n $s');
        }
        return InitTaskResult.error(e.toString());
      }
    }

    return InitTaskResult("{}", getSimulatedData());
  }

  @override
  Future<MainTaskResult> main(String json) async {
    try {
      var m = <String, dynamic>{};

      DemoConfig config = DemoConfig();
      // real hardware in use?
      if (!(config.isSimulation())) {
        m = getData();
      } else {
        m = getSimulatedData();
      }

      if (counter != 0) {
        await Future.delayed(const Duration(seconds: 2));
      }
      ++counter;
      return MainTaskResult(false, m);
    } on Exception catch (e, s) {
      if (gIsolateDebug) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
      return MainTaskResult.error(true, e.toString());
    } on Error catch (e, s) {
      if (gIsolateDebug) {
        print('Error details:\n $e');
        print('Stack trace:\n $s');
      }
      return MainTaskResult.error(true, e.toString());
    }
  }
}
