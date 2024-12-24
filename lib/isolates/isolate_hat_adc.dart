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

const gAnalogPin = 0;

/// Isolate to handle an analog pin/DAC of am extension hat.
class HatADCisolate extends IsolateWrapper {
  int counter = 1;
  late GroveBaseHat hat;

  HatADCisolate(super.isolateId, bool super.simulation);
  HatADCisolate.empty() : super("", "");

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    if (!(initialData as bool)) {
      try {} on Exception catch (e, s) {
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
    var values = <String, dynamic>{};

    values['c'] = counter;
    values['a'] = hat.readADCraw(gAnalogPin);

    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['a'] = 100 + Random().nextInt(100);

    return values;
  }

  @override
  InitTaskResult init() {
    if (sensorDebug) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        hat = GroveBaseHat();
        return InitTaskResult(hat.toJson(), getData());
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
