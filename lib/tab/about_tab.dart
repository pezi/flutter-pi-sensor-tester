// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/info_card.dart';
import '../components/sensor_image_info.dart';
import '../components/title_box.dart';
import '../constants.dart';
import '../flutter_internals.dart';

/// About panel with internal information.
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[
      const TitleBox(text: "Info"),
      InfoCard(
          widget: const FlutterLogo(),
          text: 'Flutter Version: ${flutterInternals['frameworkVersion']!}'),
      InfoCard(
          widget: Image.asset(
            '${assetSensorImages}dart.png',
            width: 25,
            height: 25,
          ),
          text: 'Dart Version: ${flutterInternals['dartSdkVersion']!}'),
      const TitleBox(text: 'Contact'),
      const InfoCard.mail(
        widget: Icon(
          Icons.email_outlined,
          color: Color(0xff03589D),
        ),
        email: 'peter.sauer@flutterdev.at',
      ),
      const InfoCard.url(
        widget: Icon(
          Icons.link,
          color: Color(0xff03589D),
        ),
        text: 'https://flutterdev.at',
        url: 'https://flutterdev.at',
      ),
      InfoCard.url(
        widget: Image.asset(width: 30, '${assetSensorImages}github_icon.png'),
        text: 'https://gitlab.at',
        url: 'https://gitlab.at',
      ),
      if (gUsedImages.isNotEmpty)
        const TitleBox(text: 'Icon artist attribution including link'),
    ];

    // list the attribution license of the used icon
    for (SensorImageInfo si in gUsedImages) {
      list.add(
        InfoCard.url(
            widget: Image.asset(width: 30, si.path),
            text: si.licenseText,
            url: si.licenseURL),
      );
    }
    return SafeArea(
      child: ListView(
        children: list,
      ),
    );
  }
}
