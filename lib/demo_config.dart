// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

enum ConfigEntry { simulation, i2c, serial, leds, hat, analogPin }

Map<ConfigEntry, dynamic> _gConfig = {
  ConfigEntry.simulation: true,
  ConfigEntry.i2c: 1,
  ConfigEntry.serial: "/dev/serial0",
  ConfigEntry.leds: [18, 16, 5],
  ConfigEntry.hat: "grove",
  ConfigEntry.analogPin: 0
};

/// Indicates a factory only singleton class
abstract class FactoryModel {}

DemoConfig? _config;

class DemoConfig implements FactoryModel {
  factory DemoConfig() {
    _config ??= DemoConfig._internal();
    return _config as DemoConfig;
  }

  DemoConfig._internal();

  bool isSimulation() {
    return _gConfig[ConfigEntry.simulation] as bool;
  }

  void setSimulation(bool flag) {
    _gConfig[ConfigEntry.simulation] = flag;
  }

  String getSerial() {
    return _gConfig[ConfigEntry.serial] as String;
  }

  int getI2C() {
    return _gConfig[ConfigEntry.i2c];
  }

  void setI2C(int busNum) {
    _gConfig[ConfigEntry.i2c] = busNum;
  }

  List<int> getLeds() {
    return _gConfig[ConfigEntry.leds].cast<int>();
  }

  int getAnalogPin() {
    return _gConfig[ConfigEntry.analogPin];
  }

  String getHat() {
    return _gConfig[ConfigEntry.hat];
  }

  String toJSON() {
    var buf = StringBuffer("[");
    int counter = 0;
    for (int led in getLeds()) {
      if (counter > 0) {
        buf.write(',');
      }
      buf.write(led);
      ++counter;
    }
    buf.write("]");
    return '{"${ConfigEntry.simulation.name}":${isSimulation()},"${ConfigEntry.serial.name}":"${getSerial()}","${ConfigEntry.i2c.name}": ${getI2C()},"${ConfigEntry.analogPin.name}":${getAnalogPin()},"${ConfigEntry.hat.name}" : "${getHat()}","${ConfigEntry.leds.name}":$buf }';
  }

  void update(String json) {
    var map = jsonDecode(json);
    for (var e in ConfigEntry.values) {
      _gConfig[e] = map[e.name];
    }
  }
}

void main() {
  var d = DemoConfig();
  var j = d.toJSON();
  print(j);
  d.update(j);
  j = d.toJSON();
  print(j);
}
