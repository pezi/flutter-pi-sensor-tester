import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import 'isolate_helper.dart';

// measurement pause in sec
const int measurementPause = 4;

/// Isolate to handle a Gesture (PAJ7620) sensor: gesture direction
class GestureDetectorIsolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late GestureSensor gesture;

  GestureDetectorIsolate(super.isolateId, bool super.simulation);
  GestureDetectorIsolate.empty() : super.empty();

  /// Returns the sensor data as [Map].
  Map<String, dynamic> getData() {
    var result = Gesture.nothing;

    // at start send a Gesture.nothing to the waiting UI, than
    // start with real measurement
    if (counter > 1) {
      while (result == Gesture.nothing) {
        result = gesture.getGesture();
      }
    }

    var values = <String, dynamic>{};

    values['c'] = counter;
    values['gesture'] = result.index;
    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    var directionList = Gesture.values;
    values['gesture'] =
        Gesture.values[Random().nextInt(directionList.length)].index;
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

    // real hardware in use?
    if (!(initialData as bool)) {
      try {
        i2c = I2C(gI2C);
        gesture = GestureSensor(i2c);
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
      if (!(initialData as bool)) {
        // wait until a directions is detected
        m = getData();
      } else {
        m = getSimulatedData();
        // for simulation add a pause
        if (counter != 0) {
          await Future.delayed(const Duration(seconds: measurementPause));
        }
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
