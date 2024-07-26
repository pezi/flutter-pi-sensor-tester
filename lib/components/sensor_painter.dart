// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:isolate/components/sensor_box.dart';
import 'package:isolate/components/sensor_image_info.dart';

class CustomSensorValue extends SensorBox {
  CustomSensorValue(
      {super.key,
      required int value,
      super.unit,
      super.customBackgroundColor,
      super.customBorderColor})
      : super(
            image: SensorImage.customPaint,
            imageVersion: -1,
            formattedValue: value.toString(),
            rawValue: value);
}

class SensorPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  SensorPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a Paint object to define
    // the appearance of the shape
    final Paint paint = Paint()
      ..color = backgroundColor // Set the color to green
      ..strokeWidth = 4 // Set the stroke width
      ..style = PaintingStyle.fill; // Set the style to fill

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Calculate the center and radius of the circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw a circle on the canvas using
    // the specified Paint object
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // Return false to indicate that the painting
    // should not be repainted unless necessary
    return false;
  }
}
