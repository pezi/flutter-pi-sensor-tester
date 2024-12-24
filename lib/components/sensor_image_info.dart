// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../constants.dart';
import '../dart_constants.dart';

/// Sensor data types
enum SensorDataType { int, double, string, num }

/// Known sensor_icons with number of existing image variants
enum SensorImage {
  barometer(3),
  clock(4, SensorDataType.string),
  hygrometer(5),
  iaq(2, SensorDataType.int),
  thermometer(5),
  co2(2, SensorDataType.int),
  customPaint(0, SensorDataType.num),
  h2(2, SensorDataType.int),
  ethanol(1, SensorDataType.int),
  gesture(1, SensorDataType.int),
  uv(2),
  light(2, SensorDataType.int),
  infrared(1, SensorDataType.int),
  adc(1, SensorDataType.int),
  spectrum(2, SensorDataType.int),
  lux(1, SensorDataType.int),
  ;

  const SensorImage(this.number, [this.dataType = SensorDataType.double]);

  /// number of image variants
  final int number;
  final SensorDataType dataType;
}

enum GraphicFormat { jpg, png }

/// Asset based image information
class SensorImageInfo {
  /// image asset path
  final String path;

  /// image variant numeration 1..n
  final int version;

  /// original author attribution license
  late final String licenseURL;
  late String licenseText;

  /// Image info defined by [sensor] type, [version] number and [license] text.
  SensorImageInfo(SensorImage sensor, this.version, String license,
      [GraphicFormat format = GraphicFormat.png])
      : path = '$assetSensorIconPath${sensor.name}_v$version.${format.name}' {
    var split = license.split("|");
    licenseURL = split[0];
    licenseText = split[1].trim();
  }

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SensorImageInfo &&
      other.runtimeType == runtimeType &&
      other.path == path;
}

var _gSensorImageMap = <String, SensorImageInfo>{};

/// Adds image defined by [sensor] type and [version] number.
Future<void> _addSensorImage(SensorImage sensor, int version) async {
  String licence = await rootBundle
      .loadString('$assetSensorIconPath${sensor.name}_v$version.txt');
  _gSensorImageMap['${sensor.name}_$version'] =
      SensorImageInfo(sensor, version, licence);
}

/// Prepare senor images
Future<int> initSensorImages() async {
  var index = 0;
  for (SensorImage s in SensorImage.values) {
    for (int v = 1; v <= s.number; ++v) {
      await _addSensorImage(s, v);
      index++;
    }
  }
  return index;
}

const imageMissingWarning = "Warning: image version not available!";

// internal stat for used images to build a list of image artist attribution
var gUsedImages = <SensorImageInfo>{};

/// Returns [SensorImageInfo] defined by [sensor] type and [version] number.
SensorImageInfo getSensorImageInfo(SensorImage sensor, int version) {
  if (!(version > 0 && version <= sensor.number)) {
    if (sensorDebug) {
      print(imageMissingWarning);
    }
    // fallback
    version = 1;
  }
  var tmp = '${sensor.name}_$version';
  var info = _gSensorImageMap[tmp]!;
  gUsedImages.add(info);
  return info;
}

/// Returns [AssetImage] defined by [sensor] type and [version] number.
AssetImage getSensorImage(SensorImage sensor, int version) {
  if (!(version > 0 && version <= sensor.number)) {
    if (sensorDebug) {
      print(imageMissingWarning);
    }
    // fallback
    version = 1;
  }
  var info = _gSensorImageMap['${sensor.name}_$version']!;
  gUsedImages.add(info);
  return AssetImage(info.path);
}
