// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'isolate_helper.dart';

/// Isolate to handle a MCP9808 sensor: temperature and humidity
class MCP9808isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late MCP9808 mcp9808;

  MCP9808isolate(super.isolateId, bool super.simulation);
  MCP9808isolate.empty() : super("", "");

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
    var result = mcp9808.getValue();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['t'] = result.temperature;

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
        mcp9808 = MCP9808(i2c);
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
