// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isolate/components/sensor_image_info.dart';

import '../constants.dart';
import 'info_box.dart';

/// Clock widget with icon, time and date.
class Clock extends StatefulWidget {
  /// Creates a clock with the optional clock icon variant [iconVersion].
  const Clock({super.key, this.iconVersion = 1});

  final int iconVersion;
  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  final DateFormat _formatter = DateFormat(gDateFormat);
  late String _time;
  late String _date;
  late Timer _timer;
  String? _lastDate;
  String? _lastTime;

  // update date and time only if an update is necessary
  void updateDateAndTime() {
    var tmp = _formatter.format(DateTime.now());
    if (_lastTime != null && _lastTime == tmp) {
      return;
    }
    _lastTime = tmp;
    _time = tmp.substring(11);
    String tmpDate = tmp.substring(0, 11);
    // update date only if necessary
    if (_lastDate == null) {
      _date = tmpDate;
      _lastDate = tmpDate;
    } else if (_lastDate != tmpDate) {
      _date = tmpDate;
      _lastDate = tmpDate;
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      // stop timer
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    updateDateAndTime();

    _timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) => setState(() {
              updateDateAndTime();
            }));
    super.initState();
  }

  Widget buildContent() {
    var wList = <Widget>[];

    // clock icon
    wList.add(SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Image(
            image: getSensorImage(SensorImage.clock, widget.iconVersion),
            fit: BoxFit.cover),
      ),
    ));

    var line = <Widget>[];
    var index = 0;
    // split time separated by ':'
    var split = _time.split(':');

    // rebuild time with a smaller letterSpacing for ':'
    for (var s in split) {
      line.add(Text(
        s,
        style: gSensorBoxTextStyle,
      ));
      if (index != split.length - 1) {
        line.add(
          Text(
            ':',
            style: gSensorBoxTextStyle.copyWith(
              letterSpacing: -25,
            ),
          ),
        );
      }
      ++index;
    }
    wList.add(
      const SizedBox(width: 15),
    );
    wList.add(
      Center(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: line),
      ),
    );

    // stack time and date
    Stack stack = Stack(
      children: [
        Row(children: wList),
        Positioned(
          left: 120,
          top: 99,
          child: Text(_date, style: gDateTextStyle),
        ),
      ],
    );
    return stack;
  }

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      child: buildContent(),
    );
  }
}
