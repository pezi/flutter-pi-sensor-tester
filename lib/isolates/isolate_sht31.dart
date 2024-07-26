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

class SHT31isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late SHT31 sht31;

  SHT31isolate(super.isolateId, bool super.simulation);
  SHT31isolate.empty() : super("", "");

  Map<String, dynamic> getData() {
    var result = sht31.getValues();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['t'] = result.temperature;
    values['h'] = result.humidity;

    return values;
  }

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    if (!(initialData as bool)) {
      try {
        i2c.dispose();
      } catch (e) {
        // we can do nothing
      }
    }
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
  }

  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['t'] = 18 + Random().nextDouble();
    values['h'] = 30 + Random().nextDouble();

    return values;
  }

  @override
  InitTaskResult init() {
    if (kDebugMode) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        i2c = I2C(gI2C);
        sht31 = SHT31(i2c);
        return InitTaskResult(i2c.toJson(), getData());
      } catch (e) {
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
    } catch (e) {
      if (kDebugMode) {
        print('Sensor error: $e');
      }
      return MainTaskResult.error(true, e.toString());
    }
  }
}
