// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';
import 'dashboard_abstract.dart';
import 'dashboard_sdc30_helper.dart';

class DashboardSDC30 extends Dashboard {
  const DashboardSDC30({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    return buildSDC30(result.data!);
  }
}
