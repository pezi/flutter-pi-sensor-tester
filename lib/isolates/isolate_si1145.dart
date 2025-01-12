// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import '../demo_config.dart';
import 'isolate_helper.dart';

// measurement pause in sec
const int measurementPause = 5;

// SI1145result getValues() {
//  return SI1145result(getVisible(), getIR(), getUVindexRaw());

/// Isolate to handle a SI1145 sensor: visible & IR light and UV index
class SI1145isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late SI1145 si1145;

  SI1145isolate(super.isolateId, String super.initialData) {
    DemoConfig().update(initialData as String);
  }
  SI1145isolate.empty() : super.empty();

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    var result = si1145.getValues();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['visible'] = result.visible;
    values['ir'] = result.ir;
    values['uvIndex'] = result.getUVindex();
    values['i2c'] = i2c.busNum;
    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['visible'] = 260 + Random().nextInt(3);
    values['ir'] = 250 + Random().nextInt(3);
    values['uvIndex'] = 0.1 + Random().nextDouble();
    values['i2c'] = DemoConfig().getI2C();
    return values;
  }

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    // real hardware in use?
    DemoConfig config = DemoConfig();
    if (!(config.isSimulation())) {
      try {
        i2c.dispose();
      } on Exception catch (e, s) {
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

    // handle program control flow
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
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
        i2c = I2C(config.getI2C());
        si1145 = SI1145(i2c);
        return InitTaskResult(i2c.toJson(), getData());
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

      // real hardware in use?
      DemoConfig config = DemoConfig();
      // real hardware in use?
      if (!(config.isSimulation())) {
        m = getData();
      } else {
        m = getSimulatedData();
      }

      if (counter != 0) {
        await Future.delayed(const Duration(seconds: measurementPause));
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
