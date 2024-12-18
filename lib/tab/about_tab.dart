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
          widget: Icon(
            Icons.info_outline,
            color: gInfoIconColor,
            size: 25.0,
          ),
          text: 'App Version: $appVersion'),
      const TitleBox(text: 'Contact'),
      const InfoCard.mail(
        widget: Icon(
          Icons.email_outlined,
          color: gInfoIconColor,
        ),
        email: 'peter.sauer@flutterdev.at',
      ),
      const InfoCard.url(
        widget: Icon(
          Icons.link,
          color: gInfoIconColor,
        ),
        text: 'https://flutterdev.at',
        url: 'https://flutterdev.at',
      ),
      InfoCard.url(
        widget: Image.asset(width: 30, '${assetSensorImages}github_icon.png'),
        text: 'https://github.com/pezi',
        url: 'https://github.com/pezi',
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
