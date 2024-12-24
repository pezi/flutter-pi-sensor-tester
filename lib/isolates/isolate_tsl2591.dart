// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import 'isolate_helper.dart';

// measurement pause in sec
const int measurementPause = 5;

// SI1145result getValues() {
//  return SI1145result(getVisible(), getIR(), getUVindexRaw());

/// Isolate to handle a SI1145 sensor: visible & IR light and UV index
class TSL2591isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late TSL2591 tsl2591;

  TSL2591isolate(super.isolateId, bool super.simulation);
  TSL2591isolate.empty() : super.empty();

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    var result = tsl2591.getRawLuminosity();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['visible'] = result.getVisible();
    values['ir'] = result.getInfraRed();
    values['lux'] = result.getLux();
    values['full'] = result.getFullSpectrum();

    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;

    values['c'] = counter;
    var visible = 87820974 + Random().nextInt(100);
    values['visible'] = visible;
    var ir = 1384 + Random().nextInt(10);
    values['ir'] = ir;
    values['lux'] = 90 + Random().nextInt(3);
    values['full'] = ir + visible;

    return values;
  }

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    // real hardware in use?
    if (!(initialData as bool)) {
      try {
        i2c.dispose();
      } on Exception catch (e, s) {
        if (sensorDebug) {
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
      } on Error catch (e, s) {
        if (sensorDebug) {
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
    if (sensorDebug) {
      print('Isolate init task');
    }

    // real hardware in use?
    if (!(initialData as bool)) {
      try {
        i2c = I2C(gI2C);
        tsl2591 = TSL2591(i2c);
        return InitTaskResult(i2c.toJson(), getData());
      } on Exception catch (e, s) {
        if (sensorDebug) {
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
        return InitTaskResult.error(e.toString());
      } on Error catch (e, s) {
        if (sensorDebug) {
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
      if (!(initialData as bool)) {
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
      if (sensorDebug) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
      return MainTaskResult.error(true, e.toString());
    } on Error catch (e, s) {
      if (sensorDebug) {
        print('Error details:\n $e');
        print('Stack trace:\n $s');
      }
      return MainTaskResult.error(true, e.toString());
    }
  }
}
