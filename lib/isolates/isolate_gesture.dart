import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:dart_periphery/dart_periphery.dart';

import '../dart_constants.dart';
import '../demo_config.dart';
import 'isolate_helper.dart';

// measurement pause in sec
const int measurementPause = 4;

/// Isolate to handle a Gesture (PAJ7620) sensor: gesture direction
class GestureDetectorIsolate extends IsolateWrapper {
  int counter = 1;
  late I2C i2c;
  late GestureSensor gesture;

  GestureDetectorIsolate(super.isolateId, String super.initialData) {
    DemoConfig().update(initialData as String);
  }
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
    values['i2c'] = i2c.busNum;
    return values;
  }

  /// Returns simulated sensor data.
  Map<String, dynamic> getSimulatedData() {
    var values = <String, dynamic>{};
    values['c'] = counter;
    var directionList = Gesture.values;
    values['gesture'] =
        Gesture.values[Random().nextInt(directionList.length)].index;
    values['i2c'] = DemoConfig().getI2C();
    return values;
  }

  @override
  void processData(SendPort sendPort, Object data) {
    String cmd = data as String;
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
    if (!(config.isSimulation())) {
      try {
        i2c = I2C(config.getI2C());
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
      DemoConfig config = DemoConfig();
      // real hardware in use?
      if (!(config.isSimulation())) {
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
