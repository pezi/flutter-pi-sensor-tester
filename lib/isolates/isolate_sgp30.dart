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

class SGP30isolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late SGP30 sgp30;

  SGP30isolate(super.isolateId, bool super.simulation);
  SGP30isolate.empty() : super("", "");

  Map<String, dynamic> getData() {
    var raw = sgp30.measureRaw();
    var iaq = sgp30.measureIaq();

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['co2'] = iaq.co2Equivalent;
    values['voc'] = iaq.totalVOC;

    values['ethanol'] = raw.ethanol;
    values['h2'] = raw.h2;

    return values;
  }

  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['co2'] = 500 + Random().nextInt(2);
    values['voc'] = 23 + Random().nextInt(10);

    values['ethanol'] = 10000 + Random().nextInt(100);
    values['h2'] = 12000 + Random().nextInt(100);

    return values;
  }

  @override
  InitTaskResult init() {
    if (kDebugMode) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        print('1');
        i2c = I2C(gI2C);
        print('2');
        sgp30 = SGP30(i2c);
        print('3');
        print('ok');
        return InitTaskResult(i2c.toJson(), getData());
      } catch (e) {
        return InitTaskResult.error(e.toString());
      }
    }

    return InitTaskResult("{}", getSimulatedData());
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
      Isolate.exit();
    }
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
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
