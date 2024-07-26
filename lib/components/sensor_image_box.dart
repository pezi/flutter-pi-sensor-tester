// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:isolate/constants.dart';

import 'info_box.dart';

const measurementLabel = 'Measurement:';

/// Adjust string to [measurementLabel] by padding spaces
extension Padding on String {
  String padding() {
    var mLen = measurementLabel.length - 1;
    String tmp = this;
    var pos = indexOf(':');
    if (pos > 0 && pos < mLen) {
      tmp = substring(0, pos) + ''.padRight(mLen - pos, ' ') + substring(pos);
    }
    return tmp;
  }
}

/// Info box which displays some sensor information.
class SensorImageBox extends StatelessWidget {
  const SensorImageBox(
      {super.key,
      required this.sensor,
      required this.interface,
      required this.icon,
      this.padding = 15,
      required this.counter});
  final String sensor;
  final String interface;
  final String icon;
  final int counter;
  final double padding;

  @override
  Widget build(BuildContext context) {
    var wList = <Widget>[];
    // add the image
    wList.add(SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Image(
            image: AssetImage('$assetSensorIconPath$icon'),
            fit: BoxFit.fitHeight),
      ),
    ));

    wList.add(SizedBox(
      width: padding,
    ));
    wList.add(Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sensor.padding(),
            style: gSensorInfoTextStyle,
          ),
          Text(
            interface.padding(),
            style: gSensorInfoTextStyle,
          ),
          Text(
            'Measurement: $counter',
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
