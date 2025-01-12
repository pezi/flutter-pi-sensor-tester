// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_leds.dart';

import '../constants.dart';
import '../dart_constants.dart';
import '../isolates/isolate_helper.dart';
import 'info_box.dart';

/// global map for storing the led pressed counter
Map<LedColor, int> gLedCounter = {
  LedColor.red: 0,
  LedColor.green: 0,
  LedColor.yellow: 0
};

/// global map for storing the button pressed status
Map<LedColor, bool> gLedStatus = {
  LedColor.red: false,
  LedColor.green: false,
  LedColor.yellow: false
};

/// Box with a button which represents a [color] led with the [status] on or off
/// and a [label] including a button pressed [counter]. [isolateId] is used
/// internally for communication with the [LedsIsolate] instance.
class LedBox extends StatelessWidget {
  const LedBox(
      {super.key,
      required this.counter,
      required this.label,
      required this.status,
      required this.isolateId,
      required this.color});
  final String isolateId;
  final int counter;

  final String label;
  final bool status;
  final LedColor color;

  @override
  Widget build(BuildContext context) {
    var wList = <Widget>[];
    bool status = gLedStatus[color] as bool;
    // add the image
    wList.add(
      SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: IconButton(
            iconSize: 90,
            icon: const Icon(Icons.lightbulb),
            color: status ? Color(color.color) : Colors.black54,
            onPressed: () {
              // get the running isolate by Id
              IsolateHelper ih = getByIsolateId(isolateId) as IsolateHelper;
              // change led status and button pressed counter
              gLedStatus[color] = !gLedStatus[color]!;
              gLedCounter[color] = (gLedCounter[color] as int) + 1;
              // set changed led status to the isolate
              ih.sendPort?.send([color.index, gLedStatus[color]]);
            },
          ),
        ),
      ),
    );

    wList.add(const SizedBox(
      width: 15,
    ));
    wList.add(Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: gSensorInfoTextStyle,
          ),
          Text(
            "Led status: ${status ? "on" : " off"}",
            style: gSensorInfoTextStyle,
          ),
          Text(
            'Counter: $counter',
            style: gSensorInfoTextStyle,
          )
        ],
      ),
    ));

    return InfoBox(
      child: Row(
        children: wList,
      ),
    );
  }
}
