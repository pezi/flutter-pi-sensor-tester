// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/constants.dart';

import '../dart_constants.dart';
import 'info_box.dart';

/// Overview box widget which displays some sensor information.
class OverviewBox extends StatelessWidget {
  const OverviewBox({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.padding = 15,
    required this.type,
  });
  final DashboardType type;
  final String title;
  final String description;
  final String image;

  final double padding;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];

    // add the image
    widgetList.add(SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Image(
            image: AssetImage('$assetSensorIconPath$image'),
            fit: BoxFit.fitHeight),
      ),
    ));

    widgetList.add(SizedBox(
      width: padding,
    ));
    widgetList.add(Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: gSensorInfoTextStyle,
          ),
          Text(
            description,
            style: gOverviewDescriptionTextStyle,
          ),
        ],
      ),
    ));

    return InfoBox(
      child: Row(
        children: widgetList,
      ),
    );
  }
}
