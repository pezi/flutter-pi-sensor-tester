// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart';
import 'info_box.dart';

/// 'Waiting for data...' widget
class WaitingForData extends StatelessWidget {
  final bool scaffold;
  const WaitingForData({super.key, this.scaffold = false});

  @override
  Widget build(BuildContext context) {
    var widget = Center(
      child: InfoBox(
        width: 250,
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    color: gNavBarBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'waiting for data...',
                style: gSensorInfoTextStyle,
              )
            ],
          ),
        ),
      ),
    );
    if (scaffold) {
      return Scaffold(body: widget);
    }
    return widget;
  }
}
