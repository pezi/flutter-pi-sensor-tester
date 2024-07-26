// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/foundation.dart';

import 'isolate_helper.dart';

class CozIRisolate extends IsolateWrapper {
  int counter = 1;
  late Serial serial;

  CozIRisolate(super.isolateId, bool super.simulation);
  CozIRisolate.empty() : super.empty();

  Map<String, dynamic> parserResult(String line) {
    //
    //  H 00469 T 01242 Z 04894
    //  https://cdn.shopify.com/s/files/1/0019/5952/files/CozIR-A_Data_Sheet_Rev_4.7.pdf
    var values = <String, dynamic>{};

    // humidity
    int pos = line.indexOf("H") + 2;
    values['h'] = double.parse(line.substring(pos, pos + 5)) / 10.0;

    pos = line.indexOf("T") + 2;
    values['t'] = (double.parse(line.substring(pos, pos + 5)) - 1000) / 10.0;

    // CO2 ppm
    pos = line.indexOf("Z") + 2;
    values['co2'] = (int.parse(line.substring(pos, pos + 5).trim())) ~/ 10;

    return values;
  }

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
    if (!(initialData as bool)) {
      try {
        serial.dispose();
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

  Map<String, dynamic> getData() {
    serial.writeString('Q\r\n');
    var event = serial.read(256, 1000);

    var values = parserResult(event.toString());
    values['c'] = counter;
    return values;
  }

  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    values['t'] = 18 + Random().nextDouble();
    values['h'] = 30 + Random().nextDouble();
    values['co2'] = 500 + Random().nextInt(40);

    return values;
  }

  @override
  InitTaskResult init() {
    if (kDebugMode) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        serial = Serial('/dev/serial0', Baudrate.b9600);
        if (kDebugMode) {
          print('Serial interface info: ${serial.getSerialInfo()}');
          // Return firmware version and sensor serial number - two lines
          serial.writeString('Y\r\n');
          var event = serial.read(256, 1000);
          print(event.toString());
        }

        // Request temperature, humidity and CO2 level.
        serial.writeString('M 4164\r\n');
        // Select polling mode
        serial.writeString('K 2\r\n');
        // print any response
        var event = serial.read(256, 1000);
        if (kDebugMode) {
          print('Response ${event.toString()}');
        }
        sleep(const Duration(seconds: 2));
        var map = getData();
        sleep(const Duration(seconds: 5));
        return InitTaskResult(serial.toJson(), map);
      } catch (e, _) {
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
        await Future.delayed(const Duration(seconds: 10));
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
