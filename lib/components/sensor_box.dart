// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_pi_sensor_tester/components/sensor_image_info.dart';
import 'package:flutter_pi_sensor_tester/components/sensor_painter.dart';
import 'package:flutter_pi_sensor_tester/constants.dart';

import 'info_box.dart';

/// Sensor widget to display sensor data.
class SensorBox extends StatelessWidget {
  final SensorImage image;
  final int imageVersion;
  final double padding;
  final String formattedValue;
  final num rawValue;
  final String unit;
  final Color customBackgroundColor;
  final Color customBorderColor;
  final bool showUnit;
  final String additionalText;
  final int additionalColor;

  const SensorBox(
      {super.key,
      required this.image,
      this.padding = 15,
      required this.imageVersion,
      required this.formattedValue,
      required this.rawValue,
      this.unit = '',
      this.showUnit = true,
      this.additionalText = '',
      this.additionalColor = 0,
      this.customBackgroundColor = Colors.green,
      this.customBorderColor = Colors.black});

  Widget buildContent() {
    var wList = <Widget>[];

    if (image == SensorImage.customPaint) {
      wList.add(
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              CustomPaint(
                  size: const Size(100, 100),
                  painter: SensorPainter(
                    backgroundColor: customBackgroundColor,
                    borderColor: customBorderColor,
                  )),
              Center(
                  child: Text(
                unit,
                style: gSensorBoxUnitTextStyle,
              )) //
            ],
          ),
        ),
      );
    } else {
      // add the image
      wList.add(SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Image(
              image: getSensorImage(image, imageVersion), fit: BoxFit.cover),
        ),
      ));
    }

    if (padding > 0) wList.add(SizedBox(width: padding));

    var line = <Widget>[];

    if (image.dataType == SensorDataType.double ||
        (image.dataType == SensorDataType.num && rawValue is double)) {
      var numberParts = formattedValue.split('.');
      line.add(Text(
        numberParts[0],
        style: gSensorBoxTextStyle,
      ));
      line.add(Text(gDecimalPoint,
          style: gSensorBoxTextStyle.copyWith(
            letterSpacing: -25,
          )));
      line.add(Text(
        numberParts[1],
        style: gSensorBoxTextStyle,
      ));
    } else {
      TextStyle style;
      if (image == SensorImage.gesture) {
        style = gSensorBoxTextStyle.copyWith(fontSize: 25);
      } else {
        style = gSensorBoxTextStyle;
      }
      line.add(Text(
        formattedValue,
        style: style,
      ));
    }

    if (image == SensorImage.thermometer) {
      line.add(Text(
        '°',
        style: gSensorBoxTextStyle,
      ));
    } else if (image == SensorImage.co2) {
      line.add(gUnitSpace);
      line.add(Text(
        'ppm',
        style: gSensorBoxUnitTextStyle,
      ));
    } else if ((image == SensorImage.light || image == SensorImage.infrared) &&
        showUnit) {
      line.add(gUnitSpace);
      line.add(Text(
        'nm',
        style: gSensorBoxUnitTextStyle,
      ));
    } else if (image == SensorImage.hygrometer) {
      line.add(gUnitSpace);
      line.add(Text(
        '%',
        style: gSensorBoxUnitTextStyle,
      ));
    } else if (image == SensorImage.barometer) {
      line.add(gUnitSpace);
      line.add(Text(
        'hPa',
        style: gSensorBoxUnitTextStyle,
      ));
    } else if (image == SensorImage.lux) {
      line.add(gUnitSpace);
      line.add(Text(
        'Lux',
        style: gSensorBoxUnitTextStyle,
      ));
    } else if (image == SensorImage.iaq) {
      var line = <Widget>[];
      line.add(Text(
        formattedValue,
        style: gSensorBoxTextStyle,
      ));
      line.add(gUnitSpace);
      line.add(Text(
        'IAQ',
        style: gSensorBoxUnitTextStyle,
      ));

      // iaq data extraction moved to ab independent file to make this code
      // usable for Flutter web without relying on the dart_periphery
      // dependency!
      //
      // AirQuality iaq = getAirQuality((rawValue as int));
      // Text quality = Text(iaq.toString(), style: gSensorBoxIAQTextStyle);

      line.add(gUnitSpace);

      Text quality = Text(additionalText, style: gSensorBoxIAQTextStyle);
      wList.add(Center(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: line),
      ));
      Stack stack = Stack(
        children: [
          Row(children: wList),
          Positioned(left: 120, top: 99, child: quality),
          Positioned(
            left: 345,
            top: 38,
            child: Container(
              decoration: BoxDecoration(
                color: Color(additionalColor),
                border: Border.all(color: Colors.grey),
                // borderRadius: BorderRadius.circular(12),
              ),
              width: 80,
              height: 70,
            ),
          )
        ],
      );
      return stack;
    }

    wList.add(
      Center(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: line),
      ),
    );

    return Row(children: wList);
  }

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      child: buildContent(),
    );
  }
}

class GestureDetector extends SensorBox {
  GestureDetector(
      {super.key,
      required super.imageVersion,
      required String gesture,
      required int index})
      : super(
            image: SensorImage.gesture,
            formattedValue: gesture,
            rawValue: index);
}

class Thermometer extends SensorBox {
  Thermometer(
      {super.key, required super.imageVersion, required double temperature})
      : super(
            image: SensorImage.thermometer,
            formattedValue: gTemperatureFormat.format(temperature),
            rawValue: temperature);
}

class VisibleLight extends SensorBox {
  VisibleLight(
      {super.key,
      required super.imageVersion,
      required int visible,
      super.showUnit = true})
      : super(
            image: SensorImage.light,
            formattedValue: visible.toString(),
            rawValue: visible);
}

class Infrared extends SensorBox {
  Infrared(
      {super.key,
      required super.imageVersion,
      required int infrared,
      super.showUnit = true})
      : super(
            image: SensorImage.infrared,
            formattedValue: infrared.toString(),
            rawValue: infrared);
}

class Spectrum extends SensorBox {
  Spectrum({super.key, required super.imageVersion, required int spectrum})
      : super(
            image: SensorImage.spectrum,
            formattedValue: spectrum.toString(),
            rawValue: spectrum);
}

class Lux extends SensorBox {
  Lux({super.key, required super.imageVersion, required int lux})
      : super(
            image: SensorImage.lux,
            formattedValue: lux.toString(),
            rawValue: lux);
}

class ADC extends SensorBox {
  ADC({super.key, required super.imageVersion, required int value})
      : super(
            image: SensorImage.adc,
            formattedValue: value.toString(),
            rawValue: value);
}

class Barometer extends SensorBox {
  Barometer({super.key, required super.imageVersion, required double pressure})
      : super(
            image: SensorImage.barometer,
            formattedValue: gPressureFormat.format(pressure),
            rawValue: pressure);
}

class UVindex extends SensorBox {
  UVindex({super.key, required super.imageVersion, required double uvIndex})
      : super(
            image: SensorImage.uv,
            formattedValue: gUVindexFormat.format(uvIndex),
            rawValue: uvIndex);
}

class Hygrometer extends SensorBox {
  Hygrometer({super.key, required super.imageVersion, required double humidity})
      : super(
            image: SensorImage.hygrometer,
            formattedValue: gPressureFormat.format(humidity),
            rawValue: humidity);
}

/// Index air quality
class IAQ extends SensorBox {
  IAQ(
      {super.key,
      required super.imageVersion,
      required int iaq,
      required String iaqText,
      required int iaqColor})
      : super(
            image: SensorImage.iaq,
            formattedValue: iaq.toString(),
            rawValue: iaq,
            additionalText: iaqText,
            additionalColor: iaqColor);
}

class CO2 extends SensorBox {
  CO2({super.key, required super.imageVersion, required int co2})
      : super(
            image: SensorImage.co2,
            formattedValue: co2.toString(),
            rawValue: co2);
}

class Ethanol extends SensorBox {
  Ethanol({super.key, required super.imageVersion, required int ethanol})
      : super(
            image: SensorImage.ethanol,
            formattedValue: ethanol.toString(),
            rawValue: ethanol);
}

class H2 extends SensorBox {
  H2({super.key, required super.imageVersion, required int h2})
      : super(
            image: SensorImage.h2, formattedValue: h2.toString(), rawValue: h2);
}
