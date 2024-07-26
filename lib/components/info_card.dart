// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

/// Opens an [url] link inside a build [context]. If an error occurs, a
/// snack bar with an error message will be shown.
Future<void> open(BuildContext context, String url) async {
  var result = await launchUrl(Uri.parse(url));

  if (context.mounted && !result) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: gBulletColor,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 35,
        child: const Center(
          child: Text('Unable to open link', style: gTextStyle),
        ),
      ),
    ));
  }
}

/// Supported info types
enum CardType { text, url, mail }

/// Info card with optional url for [CardType.url] and [CardType.mail].
class InfoCard extends StatelessWidget {
  final Widget widget;
  final String text;
  final String url;
  final CardType cardType;

  /// Creates an URL card with a leading information [widget], a [url] and a [text].
  const InfoCard.url(
      {super.key, required this.widget, required this.url, required this.text})
      : cardType = CardType.url;

  /// Creates an email card with a leading information [widget] and an [email]
  /// as URL target.
  const InfoCard.mail({super.key, required this.widget, required String email})
      : text = email,
        url = 'mailto:$email',
        cardType = CardType.mail;

  /// Creates a text card with a leading information [widget] and a [text].
  const InfoCard({super.key, required this.widget, required this.text})
      : url = '',
        cardType = CardType.text;

  @override
  Widget build(BuildContext context) {
    var card = Card(
        color: gInfoBoxBackground,
        elevation: 1,
        surfaceTintColor: Colors.grey,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: ListTile(
          leading: widget,
          title: Text(
            text,
            style: gTextStyle,
          ),
        ));
    if (cardType == CardType.text) {
      return card;
    }

    return InkWell(
      onTap: () {
        open(context, url);
      },
      child: card,
    );
  }
}
