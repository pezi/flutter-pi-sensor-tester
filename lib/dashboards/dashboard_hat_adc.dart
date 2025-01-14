// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/dashboards/dashboard_hat_adc_helper.dart';
import 'package:flutter_pi_sensor_tester/isolates/isolate_helper.dart';
import 'dashboard_abstract.dart';

class DashboardHatADC extends Dashboard {
  const DashboardHatADC({super.key, required super.isolateWrapper});

  @override
  Map<int, Widget> buildUI(TaskResult result) {
    return buildHatADC(result.data!);
  }
}
