// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../dart_constants.dart';

Map<String, dynamic> createDataMap(DashboardType sensor) {
  var map = <String, dynamic>{};
  map['sensor'] = sensor.name;
  return map;
}
