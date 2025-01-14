// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';

import 'dashboard_abstract.dart';
import 'dashboard_mlx90615_helper.dart';

class DashboardMLX90615 extends Dashboard {
  const DashboardMLX90615({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    return buildMLX90615(result.data!);
  }
}
