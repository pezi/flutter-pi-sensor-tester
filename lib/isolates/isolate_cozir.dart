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
const int measurementPause = 10;

/// Isolate to handle a CozIr CO₂ sensor: temperature, humidity and CO₂
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

    // temperature
    pos = line.indexOf("T") + 2;
    values['t'] = (double.parse(line.substring(pos, pos + 5)) - 1000) / 10.0;

    // CO₂ ppm
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
    if (cmd == 'exit') {
      exit(0);
    }
    if (cmd == 'quit') {
      Isolate.exit();
    }
  }

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    serial.writeString('Q\r\n');
    var event = serial.read(256, 1000);

    var values = parserResult(event.toString());
    values['c'] = counter;
    return values;
  }

  /// Returns simulated sensor data.
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
    if (gIsolateDebug) {
      print('Isolate init task');
    }

    if (!(initialData as bool)) {
      try {
        serial = Serial('/dev/serial0', Baudrate.b9600);
        if (gIsolateDebug) {
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
        if (gIsolateDebug) {
          print('Response ${event.toString()}');
        }
        sleep(const Duration(seconds: 2));
        var map = getData();
        sleep(const Duration(seconds: 5));
        return InitTaskResult(serial.toJson(), map);
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
