import '../dart_constants.dart';

Map<String, dynamic> createDataMap(DashboardType sensor) {
  var map = <String, dynamic>{};

  map['i2c'] = getI2Cbus();
  map['sensor'] = sensor.name;
  return map;
}
