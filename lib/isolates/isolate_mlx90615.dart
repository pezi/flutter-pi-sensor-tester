// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import 'isolate_helper.dart';

/// Isolate to handle a MLX90615 sensor: temperature and humidity
class MLX90615isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late MLX90615 mlx90615;

  MLX90615isolate(super.isolateId, bool super.simulation);
  MLX90615isolate.empty() : super("", "");

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
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
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
  }

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    var result = mlx90615.getObjectTemperature();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['t'] = result;

    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['t'] = 18 + Random().nextDouble();

    return values;
  }

  @override
  InitTaskResult init() {
    if (sensorDebug) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        i2c = I2C(gI2C);
        mlx90615 = MLX90615(i2c);
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

      if (!(initialData as bool)) {
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
