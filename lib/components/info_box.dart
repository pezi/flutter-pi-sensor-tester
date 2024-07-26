// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart';

/// Info box for decorating content.
class InfoBox extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  /// Creates a info box with [width] and [height] for a widget [child].
  const InfoBox(
      {super.key, required this.child, this.width = 480, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: gBoxBackgroundColor,
          border: Border.all(
            color: gBoxBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: width,
        height: height,
        child: child);
  }
}
