import '../dart_constants.dart';

Map<String, dynamic> createDataMap(DashboardType sensor) {
  var map = <String, dynamic>{};

  map['i2c'] = 1;
  map['sensor'] = sensor.name;
  return map;
}
