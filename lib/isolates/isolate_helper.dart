// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

import 'package:async/async.dart';

import 'isolate_factory.dart';

// https://dart.dev/language/isolates#implementing-a-simple-worker-isolate

/// generic task result
abstract class TaskResult {
  final bool error;
  final Map<String, dynamic>? data;
  TaskResult(this.error, [this.data]);

  String toJson() {
    if (data == null || data!.isEmpty) {
      return '{}';
    }
    var map = data as Map<String, dynamic>;
    var buf = StringBuffer();
    var index = 0;
    buf.write('{');
    for (String key in map.keys) {
      if (key.startsWith("_")) {
        // TODO - add internal infos
        continue;
      }
      if (index > 0) {
        buf.write(',');
      }
      buf.write('"$key":');
      var v = map[key];
      if (v is int) {
        buf.write(v);
      } else if (v is double) {
        buf.write(v);
      } else if (v is String) {
        buf.write('${jsonEncode(v)}');
      }
      ++index;
    }

    buf.write('}');
    return buf.toString();
  }
}

/// Result of the init task
class InitTaskResult extends TaskResult {
  String json;

  /// Return value of the init task, [error] signals an error, [json] represents
  /// the device configuration and the optional user [data].
  InitTaskResult(this.json, [Map<String, dynamic>? data]) : super(false, data);

  InitTaskResult.error(String error)
      : json = '',
        super(true, IsolateError(TaskMethod.init, error).toJson());

  InitTaskResult.intern(bool error, this.json, [Map<String, dynamic>? data])
      : super(error, data);
}

/// Result of the main task method
class MainTaskResult extends TaskResult {
  bool exit;

  /// Return value of a main task, [error] signals an error, [exit] to quit the
  /// main loop and the optional user [data].
  MainTaskResult(this.exit, [Map<String, dynamic>? data]) : super(false, data);
  MainTaskResult.error(this.exit, String error)
      : super(true, IsolateError(TaskMethod.init, error).toJson());
  MainTaskResult.intern(bool error, this.exit, [Map<String, dynamic>? data])
      : super(error, data);
}

/// Result of the exit task method
class ExitTaskResult extends TaskResult {
  /// Return value of the exit task, [error] signals an error and the optional
  /// user [data].
  ExitTaskResult(super.error, [super.data]);
}

/// Number of iterations invoking the main sub task.
class TaskIteration {
  int iterations;

  /// Number of [iterations], value < 0 sets an infinite loop.
  TaskIteration(this.iterations);
  TaskIteration.infinite() : iterations = -1;
}

/// Isolate model
enum IsolateModel { loop, listener, undefined }

abstract class IsolateWrapper {
  String isolateId;
  Object initialData;
  IsolateModel isolateModel;
  IsolateWrapper(this.isolateId, this.initialData,
      [this.isolateModel = IsolateModel.loop]);
  IsolateWrapper.empty()
      : initialData = '',
        isolateId = '',
        isolateModel = IsolateModel.undefined;

  InitTaskResult init();

  /// Catch missing override
  Future<MainTaskResult> main(String json) {
    throw UnimplementedError("main() - not implemented");
  }

  /// Catch missing override
  ExitTaskResult exit(String json) {
    throw UnimplementedError("exit() - not implemented");
  }

  /// Processes [data] from the isolate initiator.
  /// Do not perform long lasting operations in the method
  /// which blocks the main task!
  void processData(SendPort sendPort, Object data) {}

  void processMainTaskResult(SendPort sendPort, MainTaskResult main) {
    var map = main.data as Map<String, dynamic>;
    map['_task'] = TaskMethod.init;
    map['_error'] = main.error;
    map['_exit'] = main.exit;
    sendPort.send(map);
  }
}

/// Sub tasks
enum TaskMethod { init, main, exit, error }

class IsolateError {
  final TaskMethod method;
  final String error;
  final int timestamp;
  IsolateError(this.method, this.error)
      : timestamp = DateTime.now().millisecondsSinceEpoch;

  IsolateError.text(this.error)
      : method = TaskMethod.error,
        timestamp = DateTime.now().millisecondsSinceEpoch;

  IsolateError.fromMap(Map<String, dynamic> map)
      : method = TaskMethod.values[map['method'] as int],
        error = map['error'] as String,
        timestamp = map['milliSecs'] as int;

  Map<String, dynamic> toJson() =>
      {'method': method.index, 'milliSecs': timestamp, "error": error};
}

/// Runs an [IsolateWrapper] based class as an isolate
class IsolateHelper {
  final IsolateWrapper className;
  final TaskIteration iterationTask;
  final Object initialData;
  final String isolateId;

  Isolate? isolate;
  String? json;
  ReceivePort? receivePort;
  SendPort? sendPort;

  IsolateHelper(
      this.className, this.iterationTask, this.isolateId, this.initialData);

  /// Kills a running isolate.
  void killIsolate() {
    receivePort!.close();
    isolate!.kill(priority: Isolate.immediate);
    _isolateHelperCache.remove(isolateId);
  }

  // Start
  Stream<TaskResult> run(IsolateModel model) async* {
    receivePort = ReceivePort();
    isolate = await Isolate.spawn<SendPort>(_isolate, receivePort!.sendPort);

    final events = StreamQueue<dynamic>(receivePort!);

    // send class info and counter as map
    sendPort = await events.next;
    var classInfo = <String, dynamic>{};

    classInfo['counter'] = iterationTask;
    classInfo['className'] = className.runtimeType.toString();
    classInfo['isolateId'] = isolateId;
    classInfo['initialData'] = initialData;
    classInfo['listeningMode'] = model == IsolateModel.listener;

    sendPort?.send(classInfo);

    // wait for init map response
    var initMap = await events.next;
    json = initMap['_json'];

    // send init data
    yield InitTaskResult.intern(
        initMap['_error'] as bool, initMap['_json'] as String, initMap);

    // if no error occurs, start looping
    if (!(initMap['_error'] as bool)) {
      var loop = true;

      while (loop) {
        var result = await events.next;
        if (result['_task'] == TaskMethod.exit) {
          yield ExitTaskResult(initMap['_error'] as bool, result);
          loop = false;
        } else {
          yield MainTaskResult.intern(
              result['_error'] as bool, result['_exit'] as bool, result);
        }
      }
    }

    sendPort?.send(null);
    await events.cancel();
  }

  /// Starts the isolate, servicing the [IsolateWrapper] API: init, main, exit
  /// Hint: according the documentation this method must be static
  static Future<void> _isolate(SendPort sendPort) async {
    final commandPort = ReceivePort();
    sendPort.send(commandPort.sendPort);

    late IsolateWrapper clazz;
    bool mainLoopRunning = false;

    commandPort.listen((message) async {
      var classInfo = <String, dynamic>{};

      if (mainLoopRunning) {
        clazz.processData(sendPort, message);
        return;
      }

      mainLoopRunning = true;
      classInfo = message;

      clazz = IsolateClassFactory.createInstance(classInfo['className']!,
          classInfo['isolateId']!, classInfo['initialData']!);
      // init task
      var initResult = clazz.init();
      var initMap = initResult.data;
      initMap = initMap ?? <String, dynamic>{};

      initMap['_task'] = TaskMethod.init;
      initMap['_error'] = initResult.error;
      initMap['_json'] = initResult.json;
      sendPort.send(initMap);
      if (initResult.error) {
        commandPort.close();
        Isolate.exit();
      }

      // wait only for commands from isolate initiator
      if (classInfo['listeningMode'] as bool) {
        // infinite loop
        while (true) {
          await Future.delayed(const Duration(days: 365));
        }
      }

      // loop main task
      int counter = (classInfo['counter'] as TaskIteration).iterations;
      bool infinite = false;
      if (counter <= 0) {
        infinite = true;
      }
      int index = 0;
      while (true) {
        if (!infinite) {
          if (index == counter) {
            break;
          }
        }

        var mainResult = await clazz.main(initResult.json);
        var mainMap = mainResult.data;
        mainMap = mainMap ?? <String, dynamic>{};
        mainMap['_task'] = TaskMethod.main;
        mainMap['_error'] = mainResult.error;
        mainMap['_exit'] = mainResult.exit;
        sendPort.send(mainMap);
        if (mainResult.exit) {
          break;
        }
        ++index;
      }

      // exit task - if the main loop is finite
      var exitResult = clazz.exit(initResult.json);
      var exitMap = exitResult.data;
      exitMap = exitMap ?? <String, dynamic>{};

      exitMap['_task'] = TaskMethod.exit;
      exitMap['_error'] = exitResult.error;
      sendPort.send(exitMap);
    });
  }
}

var _isolateStreamControllerCache = <String, StreamController<TaskResult>>{};
var _isolateHelperCache = <String, IsolateHelper>{};

/// Returns a [IsolateHelper] by its internal [id]
IsolateHelper? getByIsolateId(String id) {
  return _isolateHelperCache[id];
}

/// Removes an isolate from the internal caches
void removeIsolateFromCache(String id) {
  _isolateHelperCache.remove(id);
  _isolateStreamControllerCache.remove(id);
}

/// Starts an isolate for [isolateClass] and returns
/// a broadcast [StreamController]. Created isolate instances are cached by
/// their internal isolateId.
StreamController<TaskResult> startIsolate(IsolateWrapper isolateClass) {
  StreamController<TaskResult>? isolateStreamController;
  isolateStreamController =
      _isolateStreamControllerCache[isolateClass.isolateId];
  if (isolateStreamController == null) {
    IsolateHelper isolate = IsolateHelper(
        isolateClass,
        TaskIteration.infinite(),
        isolateClass.isolateId,
        isolateClass.initialData);
    _isolateHelperCache[isolateClass.isolateId] = isolate;
    Stream<TaskResult> isolateStream = isolate.run(isolateClass.isolateModel);
    isolateStreamController = StreamController<TaskResult>.broadcast();
    isolateStreamController.addStream(isolateStream);
    _isolateStreamControllerCache[isolateClass.isolateId] =
        isolateStreamController;
    return isolateStreamController;
  }
  return isolateStreamController;
}
