// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart_constants.dart';

// Raspberry Pi hardware defaults

const appVersion = "1.0.3";

DashboardType gDashboard = DashboardType.overview;

var assetSensorIconPath = 'assets/images/sensor_icons/';
var assetSensorImagesPath = 'assets/images/sensor_images/';
var assetSensorImages = 'assets/images/images/';

String? gPackageName = null;

void useAsPackage() {
  gPackageName = 'flutter_pi_sensor_tester';
  assetSensorIconPath = 'packages/$gPackageName/assets/images/sensor_icons/';
  assetSensorImagesPath = 'packages/$gPackageName/assets/images/sensor_images/';
  assetSensorImages = 'packages/$gPackageName/assets/images/images/';
}

/// Installed google fonts.
enum MonoFonts {
  robotoMono('Roboto Mono'),
  inconsolata('Inconsolata'),
  sono('Sono'),
  jetBrainsMono('JetBrains Mono'),
  notoSansMono('Noto Sans Mono'),
  nanumGothicCoding('Nanum Gothic Coding');

  const MonoFonts(this.label);

  final String label;
}

/// Used font for text inside a sensor box.
String gMonoFontName = MonoFonts.jetBrainsMono.name;

// https://cssgradient.io/shades-of-blue/
// collection of shades of blue
const blueGrey = Color(0xFF6699CC);
const blueYonder = Color(0xFF5072A7);
const bayernBlue = Color(0xFF0066b2);
const airSuperiorityBlue = Color(0xFF72A0C1);
const lightSteelBlue = Color(0xFFB0C4DE);
const marianBlue = Color(0xFFE1EBEE);

// global color definitions
const gNavBarBackgroundColor = bayernBlue;
const gNavBarShadowBackground = Colors.blue;
const gErrorTextColor = Colors.redAccent;
const gBoxBackgroundColor = airSuperiorityBlue;
const gBoxBorderColor = Colors.black54;
const gInfoBoxBackground = lightSteelBlue;
const gTextColor = Colors.black; //Color(0xFF444446);

const gInfoIconColor = Color(0xff03589D);

// global text styles
var gSensorBoxTextStyle = TextStyle(
    color: gTextColor,
    fontFamily: gMonoFontName,
    fontSize: 70,
    fontWeight: FontWeight.w700,
    package: gPackageName);

var gSensorInfoTextStyle = TextStyle(
    color: gTextColor,
    fontFamily: gMonoFontName,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    package: gPackageName);

var gOverviewDescriptionTextStyle = TextStyle(
    color: Colors.black87,
    fontFamily: gMonoFontName,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    package: gPackageName);

var gErrorInfoTextStyle = TextStyle(
    color: gTextColor,
    fontFamily: gMonoFontName,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    package: gPackageName);

void rebuildFont() {
  gSensorBoxTextStyle = TextStyle(
      color: gTextColor,
      fontFamily: gMonoFontName,
      fontSize: 70,
      fontWeight: FontWeight.w700,
      package: gPackageName);

  gSensorInfoTextStyle = TextStyle(
      color: gTextColor,
      fontFamily: gMonoFontName,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      package: gPackageName);

  gErrorInfoTextStyle = TextStyle(
      color: gTextColor,
      fontFamily: gMonoFontName,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      package: gPackageName);
}

var gSensorBoxUnitTextStyle = gSensorBoxTextStyle.copyWith(fontSize: 40);
var gSensorBoxIAQTextStyle = gSensorBoxTextStyle.copyWith(fontSize: 20);
var gDateTextStyle = gSensorBoxTextStyle.copyWith(
  fontSize: 20,
);

var gUnitSpace = const SizedBox(
  width: 8,
);

var gTemperatureFormat = NumberFormat('###.0');
var gUVindexFormat = NumberFormat('0.0');
var gPressureFormat = NumberFormat('###.0');
var gHumidityFormat = NumberFormat('##.0');
var gDecimalPoint = '.';
const gDateFormat = 'yyyy-MM-dd HH:mm:ss';

// font size
const gFontSize = '20';
const gFontSizeNum = 20.0;
const gFontSizeMono = '18';
const gFont = 'Roboto';
const gFontMono = 'RobotoMono';

const gBackgroundColor = Color(0xffcdcdcd); // Color(0xFFF5F7F9);
const Color gBulletColor = Color(0xff2540e2);
const Color gShadowBaseColor = Color(0xffcdcdcd);

const gTextStyle = TextStyle(fontSize: gFontSizeNum, fontFamily: gFont);

const gTextLabelStyle = TextStyle(
    fontSize: gFontSizeNum + 3, fontFamily: gFont, fontWeight: FontWeight.w800);
