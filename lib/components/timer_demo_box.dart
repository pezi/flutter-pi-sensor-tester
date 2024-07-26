// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart';
import '../isolates/isolate_helper.dart';
import 'info_box.dart';

class TimerDemoBox extends StatelessWidget {
  const TimerDemoBox(
      {super.key,
      required this.counter,
      required this.color,
      required this.duration,
      required this.text,
      required this.isolateId});
  final String isolateId;
  final int counter;
  final Color color;
  final int duration;
  final String text;

  @override
  Widget build(BuildContext context) {
    var wList = <Widget>[];

    // add the image
    wList.add(
      SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Icon(
            Icons.timer_outlined,
            size: 90,
            color: color,
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
            text,
            style: gSensorInfoTextStyle,
          ),
          Text(
            "Timer duration: $duration sec",
            style: gSensorInfoTextStyle,
          ),
          Text(
            'Counter: $counter',
            style: gSensorInfoTextStyle,
          )
        ],
      ),
    ));
    wList.add(
      Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: blueYonder,
                child: IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    IsolateHelper ih =
                        getByIsolateId(isolateId) as IsolateHelper;

                    ih.sendPort?.send(1);
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: blueYonder,
                child: IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.remove),
                  onPressed: duration == 1
                      ? null
                      : () {
                          // due the async nature of (fast) pressing buttons,
                          // which can bypass the duration == 1 check,
                          // non valid durations must be filtered here
                          if (duration >= 2) {
                            IsolateHelper ih =
                                getByIsolateId(isolateId) as IsolateHelper;

                            ih.sendPort?.send(-1);
                          }
                        },
                ),
              )
            ]),
      ),
    );
    return InfoBox(
      child: Row(
        children: wList,
      ),
    );
  }
}
